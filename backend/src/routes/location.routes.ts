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
import {
  authenticate,
  authorize,
} from '@middleware/auth.middleware';
import {
  createLocationSchema,
  updateLocationSchema,
  validate,
} from '@validators/location.validator';

const router = Router();
router.use(authenticate);

// GET all locations
router.get('/', async (req, res, next) => {
  try {
    const { page, limit, offset } = parsePagination(req.query);
    const { search, is_active, client_id } = req.query;

    let query = db('locations')
      .join('clients', 'locations.client_id', 'clients.id')
      .select(
        'locations.*',
        'clients.name as client_name',
      );

    if (req.user?.role !== 'superadmin') {
      query = query.where('locations.client_id', req.user?.client_id);
    } else if (client_id) {
      query = query.where('locations.client_id', client_id);
    }

    if (search) {
      query = query.where((builder) => {
        builder
          .whereILike('locations.name', `%${search}%`)
          .orWhereILike('locations.address', `%${search}%`)
          .orWhereILike('locations.code', `%${search}%`);
      });
    }

    if (is_active !== undefined) {
      query = query.where('locations.is_active', is_active === 'true');
    }

    const [{ count }] = await query.clone().count('locations.id as count');
    const total = parseInt(count as string);

    const locations = await query
      .orderBy('locations.name', 'asc')
      .limit(limit)
      .offset(offset);

    sendPaginated(
      res,
      locations,
      getPaginationMeta(total, page, limit),
      'Data lokasi berhasil diambil'
    );
  } catch (error) {
    next(error);
  }
});

// GET location by ID
router.get('/:id', async (req, res, next) => {
  try {
    const location = await db('locations')
      .join('clients', 'locations.client_id', 'clients.id')
      .where('locations.id', req.params.id)
      .select(
        'locations.*',
        'clients.name as client_name',
      )
      .first();

    if (!location) throw new NotFoundError('Lokasi');
    sendSuccess(res, location, 'Detail lokasi berhasil diambil');
  } catch (error) {
    next(error);
  }
});

// CREATE location
router.post('/',
  authorize('superadmin', 'admin'),
  validate(createLocationSchema),
  async (req, res, next) => {
    try {
      const {
        client_id, name, code, address,
        latitude, longitude, radius, is_active,
      } = req.body;

      // Check duplicate name per client
      const existing = await db('locations')
        .where({ client_id, name })
        .first();
      if (existing) throw new ConflictError('Nama lokasi sudah digunakan');

      const [newLocation] = await db('locations')
        .insert({
          client_id,
          name,
          code: code || null,
          address,
          latitude,
          longitude,
          radius: radius || 100,
          is_active: is_active !== undefined ? is_active : true,
        })
        .returning('*');

      sendCreated(res, newLocation, 'Lokasi berhasil dibuat');
    } catch (error) {
      next(error);
    }
  }
);

// UPDATE location
router.put('/:id',
  authorize('superadmin', 'admin'),
  validate(updateLocationSchema),
  async (req, res, next) => {
    try {
      const { id } = req.params;

      const existing = await db('locations')
        .where('id', id)
        .first();
      if (!existing) throw new NotFoundError('Lokasi');

      const [updated] = await db('locations')
        .where('id', id)
        .update({
          ...req.body,
          updated_at: db.fn.now(),
        })
        .returning('*');

      sendSuccess(res, updated, 'Lokasi berhasil diupdate');
    } catch (error) {
      next(error);
    }
  }
);

// DELETE location
router.delete('/:id',
  authorize('superadmin', 'admin'),
  async (req, res, next) => {
    try {
      const { id } = req.params;

      const existing = await db('locations')
        .where('id', id)
        .first();
      if (!existing) throw new NotFoundError('Lokasi');

      // Check if location is used in attendances
      const usedInAttendance = await db('attendances')
        .where('location_id', id)
        .first();

      if (usedInAttendance) {
        // Soft delete
        await db('locations')
          .where('id', id)
          .update({
            is_active: false,
            updated_at: db.fn.now(),
          });
        sendSuccess(res, null, 'Lokasi berhasil dinonaktifkan');
      } else {
        // Hard delete
        await db('locations').where('id', id).delete();
        sendSuccess(res, null, 'Lokasi berhasil dihapus');
      }
    } catch (error) {
      next(error);
    }
  }
);

// GET user locations
router.get('/user/:user_id', async (req, res, next) => {
  try {
    const { user_id } = req.params;

    const locations = await db('user_locations')
      .where('user_locations.user_id', user_id)
      .where('user_locations.is_active', true)
      .join('locations', 'user_locations.location_id', 'locations.id')
      .where('locations.is_active', true)
      .select(
        'locations.id',
        'locations.name',
        'locations.address',
        'locations.latitude',
        'locations.longitude',
        'locations.radius',
        'user_locations.is_primary',
      )
      .orderBy('user_locations.is_primary', 'desc');

    sendSuccess(res, locations, 'Lokasi user berhasil diambil');
  } catch (error) {
    next(error);
  }
});

// ASSIGN location to user
router.post('/user/:user_id/assign',
  authorize('superadmin', 'admin'),
  async (req, res, next) => {
    try {
      const { user_id } = req.params;
      const { location_id, is_primary } = req.body;
      const clientId = req.user?.client_id;

      // Check user exists
      const user = await db('users')
        .where('id', user_id)
        .first();
      if (!user) throw new NotFoundError('User');

      // Check location exists
      const location = await db('locations')
        .where({ id: location_id, is_active: true })
        .first();
      if (!location) throw new NotFoundError('Lokasi');

      // Check if already assigned
      const existing = await db('user_locations')
        .where({ user_id, location_id })
        .first();

      if (existing) {
        await db('user_locations')
          .where({ user_id, location_id })
          .update({
            is_active: true,
            is_primary: is_primary || false,
            updated_at: db.fn.now(),
          });
      } else {
        await db('user_locations').insert({
          user_id,
          location_id,
          client_id: clientId,
          is_primary: is_primary || false,
          is_active: true,
        });
      }

      sendSuccess(res, null, 'Lokasi berhasil ditugaskan ke user');
    } catch (error) {
      next(error);
    }
  }
);

// REMOVE location from user
router.delete('/user/:user_id/remove/:location_id',
  authorize('superadmin', 'admin'),
  async (req, res, next) => {
    try {
      const { user_id, location_id } = req.params;

      await db('user_locations')
        .where({ user_id, location_id })
        .update({
          is_active: false,
          updated_at: db.fn.now(),
        });

      sendSuccess(res, null, 'Lokasi berhasil dihapus dari user');
    } catch (error) {
      next(error);
    }
  }
);

export default router;