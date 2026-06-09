import { Request, Response, NextFunction } from 'express';
import { db } from '@config/database';
import {
  sendSuccess,
  sendCreated,
  sendPaginated,
  sendNoContent,
  getPaginationMeta,
  parsePagination,
  parseSortQuery,
} from '@utils/response';
import {
  hashPassword,
  comparePassword,
} from '@utils/helpers';
import { AppError, NotFoundError, ConflictError } from '@utils/AppError';
import { deleteFile, getFileUrl } from '@utils/upload';
import { logger } from '@utils/logger';

// =============================================
// GET ALL USERS
// =============================================
export const getUsers = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { page, limit, offset } = parsePagination(req.query);
    const { column, order } = parseSortQuery(req.query.sort as string, [
      'fullname', 'username', 'email', 'nip',
      'status', 'created_at', 'updated_at',
    ]);

    const {
      search, status, role, client_id,
      department_id, position_id,
    } = req.query;

    // Build query
    let query = db('v_user_detail');

    // Filter by client (non-superadmin hanya lihat client sendiri)
    if (req.user?.role !== 'superadmin') {
      query = query.where('client_id', req.user?.client_id);
    } else if (client_id) {
      query = query.where('client_id', client_id);
    }

    // Search
    if (search) {
      query = query.where((builder) => {
        builder
          .whereILike('fullname', `%${search}%`)
          .orWhereILike('username', `%${search}%`)
          .orWhereILike('email', `%${search}%`)
          .orWhereILike('nip', `%${search}%`);
      });
    }

    // Filters
    if (status) query = query.where('status', status);
    if (role) query = query.where('role', role);
    if (department_id) query = query.where('department_id', department_id);
    if (position_id) query = query.where('position_id', position_id);

    // Count total
    const [{ count }] = await query.clone().count('id as count');
    const total = parseInt(count as string);

    // Get data with pagination
    const users = await query
      .orderBy(column, order)
      .limit(limit)
      .offset(offset);

    sendPaginated(
      res,
      users,
      getPaginationMeta(total, page, limit),
      'Data user berhasil diambil'
    );
  } catch (error) {
    next(error);
  }
};

// =============================================
// GET USER BY ID
// =============================================
export const getUserById = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;

    const user = await db('v_user_detail')
      .where('id', id)
      .first();

    if (!user) throw new NotFoundError('User');

    // Check access
    if (
      req.user?.role !== 'superadmin' &&
      req.user?.role !== 'admin' &&
      req.user?.id !== id
    ) {
      throw new AppError('Akses ditolak', 403);
    }

    sendSuccess(res, user, 'Data user berhasil diambil');
  } catch (error) {
    next(error);
  }
};

// =============================================
// CREATE USER
// =============================================
export const createUser = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const {
      username, password, fullname, email,
      kontak, nip, client_id, department_id,
      position_id, no_bpjs, no_jmo, status, role,
    } = req.body;

    // Check username exists
    const existingUsername = await db('users')
      .where('username', username)
      .first();
    if (existingUsername) {
      throw new ConflictError('Username sudah digunakan');
    }

    // Check email exists
    const existingEmail = await db('users')
      .where('email', email)
      .first();
    if (existingEmail) {
      throw new ConflictError('Email sudah digunakan');
    }

    // Check NIP exists
    if (nip) {
      const existingNip = await db('users')
        .where('nip', nip)
        .first();
      if (existingNip) {
        throw new ConflictError('NIP sudah digunakan');
      }
    }

    // Hash password
    const hashedPassword = await hashPassword(password);

    // Create user
    const [newUser] = await db('users')
      .insert({
        username,
        password: hashedPassword,
        fullname,
        email,
        kontak,
        nip,
        client_id,
        department_id: department_id || null,
        position_id: position_id || null,
        no_bpjs: no_bpjs || null,
        no_jmo: no_jmo || null,
        status: status || 'active',
        role: role || 'employee',
      })
      .returning('id');

    // Get created user detail
    const user = await db('v_user_detail')
      .where('id', newUser.id)
      .first();

    // Audit log
    logger.info('User created', {
      created_by: req.user?.id,
      user_id: newUser.id,
      username,
    });

    sendCreated(res, user, 'User berhasil dibuat');
  } catch (error) {
    next(error);
  }
};

// =============================================
// UPDATE USER
// =============================================
export const updateUser = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    // Check user exists
    const existingUser = await db('users')
      .where('id', id)
      .first();
    if (!existingUser) throw new NotFoundError('User');

    // Check username conflict
    if (updateData.username) {
      const conflict = await db('users')
        .where('username', updateData.username)
        .whereNot('id', id)
        .first();
      if (conflict) throw new ConflictError('Username sudah digunakan');
    }

    // Check email conflict
    if (updateData.email) {
      const conflict = await db('users')
        .where('email', updateData.email)
        .whereNot('id', id)
        .first();
      if (conflict) throw new ConflictError('Email sudah digunakan');
    }

    // Check NIP conflict
    if (updateData.nip) {
      const conflict = await db('users')
        .where('nip', updateData.nip)
        .whereNot('id', id)
        .first();
      if (conflict) throw new ConflictError('NIP sudah digunakan');
    }
    // Update user
    await db('users')
      .where('id', id)
      .update({
        ...updateData,
        updated_at: db.fn.now(),
      });

    // Get updated user detail
    const updatedUser = await db('v_user_detail')
      .where('id', id)
      .first();

    // Audit log
    logger.info('User updated', {
      updated_by: req.user?.id,
      user_id: id,
      changes: updateData,
    });

    sendSuccess(res, updatedUser, 'User berhasil diupdate');
  } catch (error) {
    next(error);
  }
};

// =============================================
// DELETE USER
// =============================================
export const deleteUser = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;

    // Check user exists
    const existingUser = await db('users')
      .where('id', id)
      .first();
    if (!existingUser) throw new NotFoundError('User');

    // Prevent delete self
    if (id === req.user?.id) {
      throw new AppError('Tidak dapat menghapus akun sendiri', 400);
    }

    // Prevent delete superadmin
    if (existingUser.role === 'superadmin') {
      throw new AppError('Tidak dapat menghapus superadmin', 400);
    }

    // Delete avatar if exists
    if (existingUser.avatar_url) {
      deleteFile(existingUser.avatar_url);
    }

    // Soft delete (update status)
    await db('users')
      .where('id', id)
      .update({
        status: 'resigned',
        updated_at: db.fn.now(),
      });

    // Audit log
    logger.info('User deleted', {
      deleted_by: req.user?.id,
      user_id: id,
      username: existingUser.username,
    });

    sendSuccess(res, null, 'User berhasil dihapus');
  } catch (error) {
    next(error);
  }
};

// =============================================
// UPLOAD AVATAR
// =============================================
export const uploadUserAvatar = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;

    if (!req.file) {
      throw new AppError('File avatar tidak ditemukan', 400);
    }

    // Check user exists
    const existingUser = await db('users')
      .where('id', id)
      .first();
    if (!existingUser) throw new NotFoundError('User');

    // Delete old avatar
    if (existingUser.avatar_url) {
      deleteFile(existingUser.avatar_url);
    }

    const avatarUrl = `uploads/avatars/${req.file.filename}`;

    // Update avatar
    await db('users')
      .where('id', id)
      .update({
        avatar_url: avatarUrl,
        updated_at: db.fn.now(),
      });

    sendSuccess(
      res,
      {
        avatar_url: getFileUrl(req, avatarUrl),
      },
      'Avatar berhasil diupload'
    );
  } catch (error) {
    next(error);
  }
};

// =============================================
// CHANGE PASSWORD
// =============================================
export const changePassword = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const { old_password, new_password } = req.body;

    // Check user exists
    const user = await db('users')
      .where('id', id)
      .first();
    if (!user) throw new NotFoundError('User');

    // Check access (only self or admin)
    if (
      req.user?.id !== id &&
      req.user?.role !== 'superadmin' &&
      req.user?.role !== 'admin'
    ) {
      throw new AppError('Akses ditolak', 403);
    }

    // Verify old password (only for self)
    if (req.user?.id === id) {
      const isMatch = await comparePassword(old_password, user.password);
      if (!isMatch) {
        throw new AppError('Password lama tidak sesuai', 400);
      }
    }

    // Hash new password
    const hashedPassword = await hashPassword(new_password);

    // Update password
    await db('users')
      .where('id', id)
      .update({
        password: hashedPassword,
        updated_at: db.fn.now(),
      });

    logger.info('Password changed', {
      changed_by: req.user?.id,
      user_id: id,
    });

    sendSuccess(res, null, 'Password berhasil diubah');
  } catch (error) {
    next(error);
  }
};

// =============================================
// RESET PASSWORD (Admin)
// =============================================
export const resetPassword = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const { new_password } = req.body;

    const user = await db('users')
      .where('id', id)
      .first();
    if (!user) throw new NotFoundError('User');

    const hashedPassword = await hashPassword(new_password);

    await db('users')
      .where('id', id)
      .update({
        password: hashedPassword,
        updated_at: db.fn.now(),
      });

    logger.info('Password reset by admin', {
      reset_by: req.user?.id,
      user_id: id,
    });

    sendSuccess(res, null, 'Password berhasil direset');
  } catch (error) {
    next(error);
  }
};

// =============================================
// GET USER PROFILE (Self)
// =============================================
export const getProfile = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const user = await db('v_user_detail')
      .where('id', req.user?.id)
      .first();

    if (!user) throw new NotFoundError('User');

    sendSuccess(res, user, 'Profil berhasil diambil');
  } catch (error) {
    next(error);
  }
};

// =============================================
// UPDATE PROFILE (Self)
// =============================================
export const updateProfile = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { fullname, kontak, email } = req.body;
    const userId = req.user?.id;

    // Check email conflict
    if (email) {
      const conflict = await db('users')
        .where('email', email)
        .whereNot('id', userId)
        .first();
      if (conflict) throw new ConflictError('Email sudah digunakan');
    }

    await db('users')
      .where('id', userId)
      .update({
        fullname,
        kontak,
        email,
        updated_at: db.fn.now(),
      });

    const updatedUser = await db('v_user_detail')
      .where('id', userId)
      .first();

    sendSuccess(res, updatedUser, 'Profil berhasil diupdate');
  } catch (error) {
    next(error);
  }
};

// =============================================
// UPDATE DEVICE INFO
// =============================================
export const updateDeviceInfo = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { device_id, device_name, device_platform } = req.body;
    const userId = req.user?.id;

    await db('users')
      .where('id', userId)
      .update({
        device_id,
        device_name,
        device_platform,
        updated_at: db.fn.now(),
      });

    sendSuccess(res, null, 'Device info berhasil diupdate');
  } catch (error) {
    next(error);
  }
};

// =============================================
// GET USER STATISTICS
// =============================================
export const getUserStatistics = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const clientId = req.user?.role === 'superadmin'
      ? req.query.client_id
      : req.user?.client_id;

    const stats = await db('users')
      .where(clientId ? { client_id: clientId } : {})
      .select(
        db.raw('COUNT(*) as total'),
        db.raw("COUNT(*) FILTER (WHERE status = 'active') as total_active"),
        db.raw("COUNT(*) FILTER (WHERE status = 'inactive') as total_inactive"),
        db.raw("COUNT(*) FILTER (WHERE status = 'suspended') as total_suspended"),
        db.raw("COUNT(*) FILTER (WHERE status = 'resigned') as total_resigned"),
        db.raw("COUNT(*) FILTER (WHERE role = 'admin') as total_admin"),
        db.raw("COUNT(*) FILTER (WHERE role = 'hr') as total_hr"),
        db.raw("COUNT(*) FILTER (WHERE role = 'employee') as total_employee"),
      )
      .first();

    sendSuccess(res, stats, 'Statistik user berhasil diambil');
  } catch (error) {
    next(error);
  }
};