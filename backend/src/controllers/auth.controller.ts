import { Request, Response, NextFunction } from 'express';
import { db } from '@config/database';
import {
  generateAccessToken,
  generateRefreshToken,
  verifyRefreshToken,
} from '@utils/jwt';
import {
  comparePassword,
  hashPassword,
} from '@utils/helpers';
import { sendSuccess } from '@utils/response';
import {
  AppError,
  NotFoundError,
  UnauthorizedError,
} from '@utils/AppError';
import { logger } from '@utils/logger';

// =============================================
// LOGIN
// =============================================
export const login = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { username, password, device_id, device_name, device_platform } = req.body;

    // Find user
    const user = await db('users')
      .where((builder) => {
        builder
          .where('username', username)
          .orWhere('email', username);
      })
      .first();

    if (!user) {
      throw new UnauthorizedError('Username atau password salah');
    }

    // Check status
    if (user.status !== 'active') {
      throw new UnauthorizedError(
        `Akun Anda ${user.status}. Hubungi administrator untuk informasi lebih lanjut`
      );
    }

    // Verify password
    const isMatch = await comparePassword(password, user.password);
    if (!isMatch) {
      throw new UnauthorizedError('Username atau password salah');
    }

    // Generate tokens
    const accessToken = generateAccessToken({
      id: user.id,
      username: user.username,
      role: user.role,
      client_id: user.client_id,
    });

    const refreshToken = generateRefreshToken(user.id);

    // Update device info & last login
    await db('users')
      .where('id', user.id)
      .update({
        device_id: device_id || user.device_id,
        device_name: device_name || user.device_name,
        device_platform: device_platform || user.device_platform,
        refresh_token: refreshToken,
        last_login: db.fn.now(),
        is_online: true,
        updated_at: db.fn.now(),
      });

    // Get user detail
    const userDetail = await db('v_user_detail')
      .where('id', user.id)
      .first();

    logger.info('User logged in', {
      user_id: user.id,
      username: user.username,
      device_id,
    });

    sendSuccess(res, {
      access_token: accessToken,
      refresh_token: refreshToken,
      token_type: 'Bearer',
      expires_in: '24h',
      user: userDetail,
    }, 'Login berhasil');
  } catch (error) {
    next(error);
  }
};

// =============================================
// REFRESH TOKEN
// =============================================
export const refreshToken = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { refresh_token } = req.body;

    if (!refresh_token) {
      throw new AppError('Refresh token tidak ditemukan', 400);
    }

    // Verify refresh token
    const decoded = verifyRefreshToken(refresh_token);

    // Find user
    const user = await db('users')
      .where({
        id: decoded.id,
        refresh_token,
        status: 'active',
      })
      .first();

    if (!user) {
      throw new UnauthorizedError('Refresh token tidak valid');
    }

    // Generate new tokens
    const newAccessToken = generateAccessToken({
      id: user.id,
      username: user.username,
      role: user.role,
      client_id: user.client_id,
    });

    const newRefreshToken = generateRefreshToken(user.id);

    // Update refresh token
    await db('users')
      .where('id', user.id)
      .update({
        refresh_token: newRefreshToken,
        updated_at: db.fn.now(),
      });

    sendSuccess(res, {
      access_token: newAccessToken,
      refresh_token: newRefreshToken,
      token_type: 'Bearer',
      expires_in: '24h',
    }, 'Token berhasil diperbarui');
  } catch (error) {
    next(error);
  }
};

// =============================================
// LOGOUT
// =============================================
export const logout = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    await db('users')
      .where('id', req.user?.id)
      .update({
        refresh_token: null,
        is_online: false,
        updated_at: db.fn.now(),
      });

    logger.info('User logged out', {
      user_id: req.user?.id,
      username: req.user?.username,
    });

    sendSuccess(res, null, 'Logout berhasil');
  } catch (error) {
    next(error);
  }
};

// =============================================
// FORGOT PASSWORD
// =============================================
export const forgotPassword = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { email } = req.body;

    const user = await db('users')
      .where('email', email)
      .first();

    // Always return success (security)
    if (!user) {
      sendSuccess(
        res, null,
        'Jika email terdaftar, instruksi reset password akan dikirim'
      );
      return;
    }

    // Generate reset token
    const resetToken = generateRandomString(32);
    const resetExpires = new Date(Date.now() + 3600000); // 1 jam

    await db('users')
      .where('id', user.id)
      .update({
        password_reset_token: resetToken,
        password_reset_expires: resetExpires,
        updated_at: db.fn.now(),
      });

    // TODO: Send email with reset token
    logger.info('Password reset requested', {
      user_id: user.id,
      email: user.email,
    });

    sendSuccess(
      res, null,
      'Jika email terdaftar, instruksi reset password akan dikirim'
    );
  } catch (error) {
    next(error);
  }
};

// =============================================
// RESET PASSWORD WITH TOKEN
// =============================================
export const resetPasswordWithToken = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { token, new_password } = req.body;

    // Find user with valid token
    const user = await db('users')
      .where('password_reset_token', token)
      .where('password_reset_expires', '>', db.fn.now())
      .first();

    if (!user) {
      throw new AppError(
        'Token reset password tidak valid atau sudah expired', 400
      );
    }

    const hashedPassword = await hashPassword(new_password);

    await db('users')
      .where('id', user.id)
      .update({
        password: hashedPassword,
        password_reset_token: null,
        password_reset_expires: null,
        updated_at: db.fn.now(),
      });

    logger.info('Password reset successfully', {
      user_id: user.id,
    });

    sendSuccess(res, null, 'Password berhasil direset');
  } catch (error) {
    next(error);
  }
};

// =============================================
// VERIFY TOKEN
// =============================================
export const verifyToken = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userDetail = await db('v_user_detail')
      .where('id', req.user?.id)
      .first();

    sendSuccess(res, {
      valid: true,
      user: userDetail,
    }, 'Token valid');
  } catch (error) {
    next(error);
  }
};