import Joi from 'joi';

export const createLocationSchema = Joi.object({
  client_id: Joi.string()
    .uuid()
    .required()
    .messages({
      'string.uuid': 'Format client_id tidak valid',
      'any.required': 'Client wajib dipilih',
    }),

  name: Joi.string()
    .min(3)
    .max(150)
    .required()
    .messages({
      'string.min': 'Nama lokasi minimal 3 karakter',
      'string.max': 'Nama lokasi maksimal 150 karakter',
      'any.required': 'Nama lokasi wajib diisi',
    }),

  code: Joi.string()
    .max(50)
    .optional()
    .allow(null, '')
    .messages({
      'string.max': 'Kode lokasi maksimal 50 karakter',
    }),

  address: Joi.string()
    .min(5)
    .max(500)
    .required()
    .messages({
      'string.min': 'Alamat minimal 5 karakter',
      'string.max': 'Alamat maksimal 500 karakter',
      'any.required': 'Alamat wajib diisi',
    }),

  latitude: Joi.number()
    .min(-90)
    .max(90)
    .required()
    .messages({
      'number.min': 'Latitude tidak valid',
      'number.max': 'Latitude tidak valid',
      'any.required': 'Latitude wajib diisi',
    }),

  longitude: Joi.number()
    .min(-180)
    .max(180)
    .required()
    .messages({
      'number.min': 'Longitude tidak valid',
      'number.max': 'Longitude tidak valid',
      'any.required': 'Longitude wajib diisi',
    }),

  radius: Joi.number()
    .integer()
    .min(10)
    .max(10000)
    .default(100)
    .messages({
      'number.min': 'Radius minimal 10 meter',
      'number.max': 'Radius maksimal 10000 meter',
    }),

  is_active: Joi.boolean()
    .default(true),
});

export const updateLocationSchema = Joi.object({
  name: Joi.string()
    .min(3)
    .max(150)
    .optional()
    .messages({
      'string.min': 'Nama lokasi minimal 3 karakter',
      'string.max': 'Nama lokasi maksimal 150 karakter',
    }),

  code: Joi.string()
    .max(50)
    .optional()
    .allow(null, ''),

  address: Joi.string()
    .min(5)
    .max(500)
    .optional()
    .messages({
      'string.min': 'Alamat minimal 5 karakter',
      'string.max': 'Alamat maksimal 500 karakter',
    }),

  latitude: Joi.number()
    .min(-90)
    .max(90)
    .optional()
    .messages({
      'number.min': 'Latitude tidak valid',
      'number.max': 'Latitude tidak valid',
    }),

  longitude: Joi.number()
    .min(-180)
    .max(180)
    .optional()
    .messages({
      'number.min': 'Longitude tidak valid',
      'number.max': 'Longitude tidak valid',
    }),
  radius: Joi.number()
    .integer()
    .min(10)
    .max(10000)
    .optional()
    .messages({
      'number.min': 'Radius minimal 10 meter',
      'number.max': 'Radius maksimal 10000 meter',
    }),

  is_active: Joi.boolean().optional(),
});

// =============================================
// Shift Validator
// =============================================
export const createShiftSchema = Joi.object({
  client_id: Joi.string()
    .uuid()
    .required()
    .messages({
      'string.uuid': 'Format client_id tidak valid',
      'any.required': 'Client wajib dipilih',
    }),

  name: Joi.string()
    .min(3)
    .max(100)
    .required()
    .messages({
      'string.min': 'Nama shift minimal 3 karakter',
      'string.max': 'Nama shift maksimal 100 karakter',
      'any.required': 'Nama shift wajib diisi',
    }),

  code: Joi.string()
    .max(50)
    .optional()
    .allow(null, ''),

  check_in_time: Joi.string()
    .pattern(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/)
    .required()
    .messages({
      'string.pattern.base': 'Format jam masuk tidak valid (HH:mm)',
      'any.required': 'Jam masuk wajib diisi',
    }),

  check_out_time: Joi.string()
    .pattern(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/)
    .required()
    .messages({
      'string.pattern.base': 'Format jam keluar tidak valid (HH:mm)',
      'any.required': 'Jam keluar wajib diisi',
    }),

  late_tolerance: Joi.number()
    .integer()
    .min(0)
    .max(120)
    .default(0)
    .messages({
      'number.min': 'Toleransi keterlambatan minimal 0 menit',
      'number.max': 'Toleransi keterlambatan maksimal 120 menit',
    }),

  early_leave_tolerance: Joi.number()
    .integer()
    .min(0)
    .max(120)
    .default(0)
    .messages({
      'number.min': 'Toleransi pulang awal minimal 0 menit',
      'number.max': 'Toleransi pulang awal maksimal 120 menit',
    }),

  is_overnight: Joi.boolean()
    .default(false),

  is_active: Joi.boolean()
    .default(true),
});

export const updateShiftSchema = createShiftSchema.fork(
  ['client_id', 'name', 'check_in_time', 'check_out_time'],
  (schema) => schema.optional()
);