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

// Schemas
const departmentSchema = Joi.object({
  client_id: Joi.string().uuid().required()
    .messages({
      'string.uuid': 'Format client_id tidak valid',
      'any.required': 'Client wajib dipilih',
    }),
  name: Joi.string().min(3).max(150).required()
    .messages({
      'string.min': 'Nama departemen minimal 3 karakter',
      'string.max': 'Nama departemen maksimal 150 karakter',
      'any.required': 'Nama departemen wajib diisi',
    }),
  code: Joi.string().max(50).optional().allow(null, ''),
  description: Joi.string().max(500).optional().allow(null, ''),
  is_active: Joi.boolean().default(true),
});

const positionSchema = Joi.object({
  client_id: Joi.string().uuid().required()
    .messages({
      'string.uuid': 'Format client_id tidak valid',
      'any.required': 'Client wajib dipilih',
    }),
  department_id: Joi.string().uuid().optional().allow(null, '')
    .messages({
      'string.uuid': 'Format department_id tidak valid',
    }),
  name: Joi.string().min(3).max(150).required()
    .messages({
      'string.min': 'Nama posisi minimal 3 karakter',
      'string.max': 'Nama posisi maksimal 150 karakter',
      'any.required': 'Nama posisi wajib diisi',
    }),
  code: Joi.string().max(50).optional().allow(null, ''),
  level: Joi.number().integer().min(1).max(10).default(1),
  is_active: Joi.boolean().default(true),
});

// =============================================
// DEPARTMENT ROUTES
// =============================================

// GET all departments
router.get('/', async (req, res, next) => {
  try {
    const { page, limit, offset } = parsePagination(req.query);
    const { search, is_active, client_id } = req.query;

    let query = db('departments')
      .join('clients', 'departments.client_id', 'clients.id')
      .select(
        'departments.*',
        'clients.name as client_name',
        db.raw('(SELECT COUNT(*) FROM users WHERE department_id = departments.id) as total_employees'),
        db.raw('(SELECT COUNT(*) FROM positions WHERE department_id = departments.id AND is_active = true) as total_positions'),
      );

    if (req.user?.role !== 'superadmin') {
      query = query.where('departments.client_id', req.user?.client_id);
    } else if (client_id) {
      query = query.where('departments.client_id', client_id);
    }

    if (search) {
      query = query.where((builder) => {
        builder
          .whereILike('departments.name', `%${search}%`)
          .orWhereILike('departments.code', `%${search}%`);
      });
    }
    if (is_active !== undefined) {
      query = query.where('departments.is_active', is_active === 'true');
    }

    const [{ count }] = await query.clone().count('departments.id as count');
    const total = parseInt(count as string);

    const departments = await query
      .orderBy('departments.name', 'asc')
      .limit(limit)
      .offset(offset);

    sendPaginated(
      res,
      departments,
      getPaginationMeta(total, page, limit),
      'Data departemen berhasil diambil'
    );
  } catch (error) {
    next(error);
  }
});

// GET department by ID
router.get('/:id', async (req, res, next) => {
  try {
    const department = await db('departments')
      .join('clients', 'departments.client_id', 'clients.id')
      .where('departments.id', req.params.id)
      .select(
        'departments.*',
        'clients.name as client_name',
      )
      .first();

    if (!department) throw new NotFoundError('Departemen');

    // Get positions in department
    const positions = await db('positions')
      .where('department_id', req.params.id)
      .where('is_active', true)
      .select('id', 'name', 'code', 'level')
      .orderBy('level', 'asc');

    // Get employees count
    const employeeCount = await db('users')
      .where('department_id', req.params.id)
      .where('status', 'active')
      .count('id as count')
      .first();

    sendSuccess(res, {
      ...department,
      positions,
      total_employees: parseInt(employeeCount?.count as string || '0'),
    }, 'Detail departemen berhasil diambil');
  } catch (error) {
    next(error);
  }
});

// CREATE department
router.post('/',
  authorize('superadmin', 'admin'),
  validate(departmentSchema),
  async (req, res, next) => {
    try {
      const { client_id, name, code, description, is_active } = req.body;

      // Check duplicate
      const existing = await db('departments')
        .where({ client_id, name })
        .first();
      if (existing) throw new ConflictError('Nama departemen sudah digunakan');

      const [newDept] = await db('departments')
        .insert({
          client_id,
          name,
          code: code || null,
          description: description || null,
          is_active: is_active !== undefined ? is_active : true,
        })
        .returning('*');

      sendCreated(res, newDept, 'Departemen berhasil dibuat');
    } catch (error) {
      next(error);
    }
  }
);

// UPDATE department
router.put('/:id',
  authorize('superadmin', 'admin'),
  async (req, res, next) => {
    try {
      const { id } = req.params;

      const existing = await db('departments')
        .where('id', id)
        .first();
      if (!existing) throw new NotFoundError('Departemen');

      if (req.body.name) {
        const duplicate = await db('departments')
          .where('client_id', existing.client_id)
          .where('name', req.body.name)
          .whereNot('id', id)
          .first();
        if (duplicate) throw new ConflictError('Nama departemen sudah digunakan');
      }

      const [updated] = await db('departments')
        .where('id', id)
        .update({
          ...req.body,
          updated_at: db.fn.now(),
        })
        .returning('*');

      sendSuccess(res, updated, 'Departemen berhasil diupdate');
    } catch (error) {
      next(error);
    }
  }
);

// DELETE department
router.delete('/:id',
  authorize('superadmin', 'admin'),
  async (req, res, next) => {
    try {
      const { id } = req.params;

      const existing = await db('departments')
        .where('id', id)
        .first();
      if (!existing) throw new NotFoundError('Departemen');

      // Check if has employees
      const hasEmployees = await db('users')
        .where('department_id', id)
        .first();

      if (hasEmployees) {
        await db('departments')
          .where('id', id)
          .update({
            is_active: false,
            updated_at: db.fn.now(),
          });
        sendSuccess(res, null, 'Departemen berhasil dinonaktifkan');
      } else {
        await db('departments').where('id', id).delete();
        sendSuccess(res, null, 'Departemen berhasil dihapus');
      }
    } catch (error) {
      next(error);
    }
  }
);

// =============================================
// POSITION ROUTES
// =============================================

// GET all positions
router.get('/positions/list', async (req, res, next) => {
  try {
    const { page, limit, offset } = parsePagination(req.query);
    const { search, is_active, client_id, department_id } = req.query;

    let query = db('positions')
      .join('clients', 'positions.client_id', 'clients.id')
      .leftJoin('departments', 'positions.department_id', 'departments.id')
      .select(
        'positions.*',
        'clients.name as client_name',
        'departments.name as department_name',
        db.raw(
          '(SELECT COUNT(*) FROM users WHERE position_id = positions.id) as total_employees'
        ),
      );

    if (req.user?.role !== 'superadmin') {
      query = query.where('positions.client_id', req.user?.client_id);
    } else if (client_id) {
      query = query.where('positions.client_id', client_id);
    }

    if (department_id) {
      query = query.where('positions.department_id', department_id);
    }

    if (search) {
      query = query.where((builder) => {
        builder
          .whereILike('positions.name', `%${search}%`)
          .orWhereILike('positions.code', `%${search}%`);
      });
    }

    if (is_active !== undefined) {
      query = query.where('positions.is_active', is_active === 'true');
    }

    const [{ count }] = await query.clone().count('positions.id as count');
    const total = parseInt(count as string);

    const positions = await query
      .orderBy('positions.level', 'asc')
      .orderBy('positions.name', 'asc')
      .limit(limit)
      .offset(offset);

    sendPaginated(
      res,
      positions,
      getPaginationMeta(total, page, limit),
      'Data posisi berhasil diambil'
    );
  } catch (error) {
    next(error);
  }
});

// CREATE position
router.post('/positions',
  authorize('superadmin', 'admin'),
  validate(positionSchema),
  async (req, res, next) => {
    try {
      const {
        client_id, department_id, name,
        code, level, is_active,
      } = req.body;

      // Check duplicate
      const existing = await db('positions')
        .where({ client_id, name })
        .first();
      if (existing) throw new ConflictError('Nama posisi sudah digunakan');

      const [newPosition] = await db('positions')
        .insert({
          client_id,
          department_id: department_id || null,
          name,
          code: code || null,
          level: level || 1,
          is_active: is_active !== undefined ? is_active : true,
        })
        .returning('*');

      sendCreated(res, newPosition, 'Posisi berhasil dibuat');
    } catch (error) {
      next(error);
    }
  }
);

// UPDATE position
router.put('/positions/:id',
  authorize('superadmin', 'admin'),
  async (req, res, next) => {
    try {
      const { id } = req.params;

      const existing = await db('positions')
        .where('id', id)
        .first();
      if (!existing) throw new NotFoundError('Posisi');

      // Check duplicate name
      if (req.body.name) {
        const duplicate = await db('positions')
          .where('client_id', existing.client_id)
          .where('name', req.body.name)
          .whereNot('id', id)
          .first();
        if (duplicate) throw new ConflictError('Nama posisi sudah digunakan');
      }

      const [updated] = await db('positions')
        .where('id', id)
        .update({
          ...req.body,
          updated_at: db.fn.now(),
        })
        .returning('*');

      sendSuccess(res, updated, 'Posisi berhasil diupdate');
    } catch (error) {
      next(error);
    }
  }
);

// DELETE position
router.delete('/positions/:id',
  authorize('superadmin', 'admin'),
  async (req, res, next) => {
    try {
      const { id } = req.params;

      const existing = await db('positions')
        .where('id', id)
        .first();
      if (!existing) throw new NotFoundError('Posisi');

      // Check if has employees
      const hasEmployees = await db('users')
        .where('position_id', id)
        .first();

      if (hasEmployees) {
        await db('positions')
          .where('id', id)
          .update({
            is_active: false,
            updated_at: db.fn.now(),
          });
        sendSuccess(res, null, 'Posisi berhasil dinonaktifkan');
      } else {
        await db('positions').where('id', id).delete();
        sendSuccess(res, null, 'Posisi berhasil dihapus');
      }
    } catch (error) {
      next(error);
    }
  }
);

export default router;