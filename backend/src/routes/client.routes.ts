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
import Joi from 'joi';
import { validate } from '@validators/user.validator';

const router = Router();
router.use(authenticate);
router.use(authorize('superadmin', 'admin'));
const clientSchema = Joi.object({
  name: Joi.string().min(3).max(150).required()
    .messages({
      'string.min': 'Nama client minimal 3 karakter',
      'string.max': 'Nama client maksimal 150 karakter',
      'any.required': 'Nama client wajib diisi',
    }),
  code: Joi.string().max(50).required()
    .messages({
      'string.max': 'Kode client maksimal 50 karakter',
      'any.required': 'Kode client wajib diisi',
    }),
  address: Joi.string().max(500).optional().allow(null, ''),
  phone: Joi.string()
    .pattern(/^[0-9+\-\s()]+$/)
    .max(20)
    .optional()
    .allow(null, '')
    .messages({
      'string.pattern.base': 'Format nomor telepon tidak valid',
    }),
  email: Joi.string().email().max(100)
    .optional().allow(null, '')
    .messages({
      'string.email': 'Format email tidak valid',
    }),
  is_active: Joi.boolean().default(true),
});

const updateClientSchema = clientSchema.fork(
  ['name', 'code'],
  (schema) => schema.optional()
);

// GET all clients
router.get('/', async (req, res, next) => {
  try {
    const { page, limit, offset } = parsePagination(req.query);
    const { search, is_active } = req.query;

    let query = db('clients');

    if (search) {
      query = query.where((builder) => {
        builder
          .whereILike('name', `%${search}%`)
          .orWhereILike('code', `%${search}%`)
          .orWhereILike('email', `%${search}%`);
      });
    }

    if (is_active !== undefined) {
      query = query.where('is_active', is_active === 'true');
    }

    const [{ count }] = await query.clone().count('id as count');
    const total = parseInt(count as string);

    const clients = await query
      .orderBy('name', 'asc')
      .limit(limit)
      .offset(offset);

    sendPaginated(
      res,
      clients,
      getPaginationMeta(total, page, limit),
      'Data client berhasil diambil'
    );
  } catch (error) {
    next(error);
  }
});

// GET client by ID
router.get('/:id', async (req, res, next) => {
  try {
    const client = await db('clients')
      .where('id', req.params.id)
      .first();

    if (!client) throw new NotFoundError('Client');

    // Get statistics
    const stats = await db('users')
      .where('client_id', req.params.id)
      .select(
        db.raw('COUNT(*) as total_users'),
        db.raw("COUNT(*) FILTER (WHERE status = 'active') as active_users"),
      )
      .first();

    const locationCount = await db('locations')
      .where('client_id', req.params.id)
      .count('id as count')
      .first();

    const shiftCount = await db('shifts')
      .where('client_id', req.params.id)
      .count('id as count')
      .first();
    sendSuccess(res, {
      ...client,
      statistics: {
        total_users: parseInt(stats?.total_users || '0'),
        active_users: parseInt(stats?.active_users || '0'),
        total_locations: parseInt(locationCount?.count as string || '0'),
        total_shifts: parseInt(shiftCount?.count as string || '0'),
      },
    }, 'Detail client berhasil diambil');
  } catch (error) {
    next(error);
  }
});

// CREATE client
router.post('/',
  authorize('superadmin'),
  validate(clientSchema),
  async (req, res, next) => {
    try {
      const { name, code, address, phone, email, is_active } = req.body;

      // Check duplicate code
      const existing = await db('clients')
        .where('code', code)
        .first();
      if (existing) throw new ConflictError('Kode client sudah digunakan');

      const [newClient] = await db('clients')
        .insert({
          name,
          code: code.toUpperCase(),
          address: address || null,
          phone: phone || null,
          email: email || null,
          is_active: is_active !== undefined ? is_active : true,
        })
        .returning('*');

      sendCreated(res, newClient, 'Client berhasil dibuat');
    } catch (error) {
      next(error);
    }
  }
);

// UPDATE client
router.put('/:id',
  authorize('superadmin'),
  validate(updateClientSchema),
  async (req, res, next) => {
    try {
      const { id } = req.params;

      const existing = await db('clients')
        .where('id', id)
        .first();
      if (!existing) throw new NotFoundError('Client');

      // Check duplicate code
      if (req.body.code) {
        const duplicate = await db('clients')
          .where('code', req.body.code)
          .whereNot('id', id)
          .first();
        if (duplicate) throw new ConflictError('Kode client sudah digunakan');
      }

      const [updated] = await db('clients')
        .where('id', id)
        .update({
          ...req.body,
          code: req.body.code
            ? req.body.code.toUpperCase()
            : existing.code,
          updated_at: db.fn.now(),
        })
        .returning('*');

      sendSuccess(res, updated, 'Client berhasil diupdate');
    } catch (error) {
      next(error);
    }
  }
);

// DELETE client
router.delete('/:id',
  authorize('superadmin'),
  async (req, res, next) => {
    try {
      const { id } = req.params;

      const existing = await db('clients')
        .where('id', id)
        .first();
      if (!existing) throw new NotFoundError('Client');

      // Check if client has users
      const hasUsers = await db('users')
        .where('client_id', id)
        .first();

      if (hasUsers) {
        // Soft delete
        await db('clients')
          .where('id', id)
          .update({
            is_active: false,
            updated_at: db.fn.now(),
          });
        sendSuccess(res, null, 'Client berhasil dinonaktifkan');
      } else {
        await db('clients').where('id', id).delete();
        sendSuccess(res, null, 'Client berhasil dihapus');
      }
    } catch (error) {
      next(error);
    }
  }
);

export default router;