import { Router } from 'express';
import { db } from '@config/database';
import {
  sendSuccess,
  sendCreated,
  sendPaginated,
  getPaginationMeta,
  parsePagination,
} from '@utils/response';
import { NotFoundError, ConflictError } from '@utils/AppError';
import { authenticate, authorize } from '@middleware/auth.middleware';
import {
  createShiftSchema,
  updateShiftSchema,
  validate,
} from '@validators/location.validator';

const router = Router();
router.use(authenticate);

// GET all shifts
router.get('/', async (req, res, next) => {
  try {
    const { page, limit, offset } = parsePagination(req.query);
    const { search, is_active, client_id } = req.query;

    let query = db('shifts')
      .join('clients', 'shifts.client_id', 'clients.id')
      .select(
        'shifts.*',
        'clients.name as client_name',
      );

    if (req.user?.role !== 'superadmin') {
      query = query.where('shifts.client_id', req.user?.client_id);
    } else if (client_id) {
      query = query.where('shifts.client_id', client_id);
    }

    if (search) {
      query = query.where((builder) => {
        builder
          .whereILike('shifts.name', `%${search}%`)
          .orWhereILike('shifts.code', `%${search}%`);
      });
    }

    if (is_active !== undefined) {
      query = query.where('shifts.is_active', is_active === 'true');
    }

    const [{ count }] = await query.clone().count('shifts.id as count');
    const total = parseInt(count as string);

    const shifts = await query
      .orderBy('shifts.name', 'asc')
      .limit(limit)
      .offset(offset);

    sendPaginated(
      res,
      shifts,
      getPaginationMeta(total, page, limit),
      'Data shift berhasil diambil'
    );
  } catch (error) {
    next(error);
  }
});

// GET shift by ID
router.get('/:id', async (req, res, next) => {
  try {
    const shift = await db('shifts')
      .join('clients', 'shifts.client_id', 'clients.id')
      .where('shifts.id', req.params.id)
      .select(
        'shifts.*',
        'clients.name as client_name',
      )
      .first();

    if (!shift) throw new NotFoundError('Shift');
    sendSuccess(res, shift, 'Detail shift berhasil diambil');
  } catch (error) {
    next(error);
  }
});

// CREATE shift
router.post('/',
  authorize('superadmin', 'admin'),
  validate(createShiftSchema),
  async (req, res, next) => {
    try {
      const {
        client_id, name, code,
        check_in_time, check_out_time,
        late_tolerance, early_leave_tolerance,
        is_overnight, is_active,
      } = req.body;

      // Check duplicate name per client
      const existing = await db('shifts')
        .where({ client_id, name })
        .first();
      if (existing) throw new ConflictError('Nama shift sudah digunakan');

      const [newShift] = await db('shifts')
        .insert({
          client_id,
          name,
          code: code || null,
          check_in_time,
          check_out_time,
          late_tolerance: late_tolerance || 0,
          early_leave_tolerance: early_leave_tolerance || 0,
          is_overnight: is_overnight || false,
          is_active: is_active !== undefined ? is_active : true,
        })
        .returning('*');

      sendCreated(res, newShift, 'Shift berhasil dibuat');
    } catch (error) {
      next(error);
    }
  }
);

// UPDATE shift
router.put('/:id',
  authorize('superadmin', 'admin'),
  validate(updateShiftSchema),
  async (req, res, next) => {
    try {
      const { id } = req.params;

      const existing = await db('shifts')
        .where('id', id)
        .first();
      if (!existing) throw new NotFoundError('Shift');

      // Check duplicate name
      if (req.body.name) {
        const duplicate = await db('shifts')
          .where('client_id', existing.client_id)
          .where('name', req.body.name)
          .whereNot('id', id)
          .first();
        if (duplicate) throw new ConflictError('Nama shift sudah digunakan');
      }

      const [updated] = await db('shifts')
        .where('id', id)
        .update({
          ...req.body,
          updated_at: db.fn.now(),
        })
        .returning('*');

      sendSuccess(res, updated, 'Shift berhasil diupdate');
    } catch (error) {
      next(error);
    }
  }
);

// DELETE shift
router.delete('/:id',
  authorize('superadmin', 'admin'),
  async (req, res, next) => {
    try {
      const { id } = req.params;

      const existing = await db('shifts')
        .where('id', id)
        .first();
      if (!existing) throw new NotFoundError('Shift');

      // Check if used in attendances
      const usedInAttendance = await db('attendances')
        .where('shift_id', id)
        .first();

      if (usedInAttendance) {
        await db('shifts')
          .where('id', id)
          .update({
            is_active: false,
            updated_at: db.fn.now(),
          });
        sendSuccess(res, null, 'Shift berhasil dinonaktifkan');
      } else {
        await db('shifts').where('id', id).delete();
        sendSuccess(res, null, 'Shift berhasil dihapus');
      }
    } catch (error) {
      next(error);
    }
  }
);

// ASSIGN shift to user
router.post('/user/:user_id/assign',
  authorize('superadmin', 'admin'),
  async (req, res, next) => {
    try {
      const { user_id } = req.params;
      const {
        shift_id,
        effective_date,
        end_date,
      } = req.body;
      const clientId = req.user?.client_id;

      // Check user exists
      const user = await db('users')
        .where('id', user_id)
        .first();
      if (!user) throw new NotFoundError('User');

      // Check shift exists
      const shift = await db('shifts')
        .where({
          id: shift_id,
          is_active: true,
        })
        .first();
      if (!shift) throw new NotFoundError('Shift');

      // Deactivate existing active shifts
      await db('user_shifts')
        .where({
          user_id,
          is_active: true,
        })
        .update({
          is_active: false,
          updated_at: db.fn.now(),
        });

      // Assign new shift
      const [newUserShift] = await db('user_shifts')
        .insert({
          user_id,
          shift_id,
          client_id: clientId,
          effective_date,
          end_date: end_date || null,
          is_active: true,
        })
        .returning('*');

      // Get detail
      const userShift = await db('user_shifts')
        .where('user_shifts.id', newUserShift.id)
        .join('shifts', 'user_shifts.shift_id', 'shifts.id')
        .join('users', 'user_shifts.user_id', 'users.id')
        .select(
          'user_shifts.*',
          'shifts.name as shift_name',
          'shifts.check_in_time',
          'shifts.check_out_time',
          'users.fullname as employee_name',
        )
        .first();

      sendCreated(res, userShift, 'Shift berhasil ditugaskan ke user');
    } catch (error) {
      next(error);
    }
  }
);

// GET user shifts history
router.get('/user/:user_id/history', async (req, res, next) => {
  try {
    const { user_id } = req.params;
    const { page, limit, offset } = parsePagination(req.query);

    const [{ count }] = await db('user_shifts')
      .where('user_id', user_id)
      .count('id as count');
    const total = parseInt(count as string);

    const shifts = await db('user_shifts')
      .where('user_shifts.user_id', user_id)
      .join('shifts', 'user_shifts.shift_id', 'shifts.id')
      .select(
        'user_shifts.*',
        'shifts.name as shift_name',
        'shifts.check_in_time',
        'shifts.check_out_time',
        'shifts.late_tolerance',
        'shifts.early_leave_tolerance',
        'shifts.is_overnight',
      )
      .orderBy('user_shifts.effective_date', 'desc')
      .limit(limit)
      .offset(offset);

    sendPaginated(
      res,
      shifts,
      getPaginationMeta(total, page, limit),
      'Riwayat shift berhasil diambil'
    );
  } catch (error) {
    next(error);
  }
});

export default router;