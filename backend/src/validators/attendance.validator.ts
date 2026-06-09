import Joi from 'joi';

export const createAttendanceSchema = Joi.object({
  location_id: Joi.string()
    .uuid()
    .required()
    .messages({
      'string.uuid': 'Format location_id tidak valid',
      'any.required': 'Lokasi wajib dipilih',
    }),

  shift_id: Joi.string()
    .uuid()
    .required()
    .messages({
      'string.uuid': 'Format shift_id tidak valid',
      'any.required': 'Shift wajib dipilih',
    }),

  type: Joi.string()
    .valid('check_in', 'check_out')
    .required()
    .messages({
      'any.only': 'Tipe absensi harus check_in atau check_out',
      'any.required': 'Tipe absensi wajib diisi',
    }),

  attendance_mode: Joi.string()
    .valid('current', 'manual')
    .default('current')
    .messages({
      'any.only': 'Mode absensi tidak valid',
    }),

  employee_latitude: Joi.number()
    .min(-90)
    .max(90)
    .when('attendance_mode', {
      is: 'current',
      then: Joi.required(),
      otherwise: Joi.optional(),
    })
    .messages({
      'number.min': 'Latitude tidak valid',
      'number.max': 'Latitude tidak valid',
      'any.required': 'Koordinat latitude wajib diisi',
    }),

  employee_longitude: Joi.number()
    .min(-180)
    .max(180)
    .when('attendance_mode', {
      is: 'current',
      then: Joi.required(),
      otherwise: Joi.optional(),
    })
    .messages({
      'number.min': 'Longitude tidak valid',
      'number.max': 'Longitude tidak valid',
      'any.required': 'Koordinat longitude wajib diisi',
    }),

  manual_date: Joi.date()
    .iso()
    .when('attendance_mode', {
      is: 'manual',
      then: Joi.required(),
      otherwise: Joi.optional().allow(null),
    })
    .messages({
      'date.iso': 'Format tanggal tidak valid (YYYY-MM-DD)',
      'any.required': 'Tanggal manual wajib diisi',
    }),

  manual_time: Joi.string()
    .pattern(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/)
    .when('attendance_mode', {
      is: 'manual',
      then: Joi.required(),
      otherwise: Joi.optional().allow(null),
    })
    .messages({
      'string.pattern.base': 'Format jam tidak valid (HH:mm)',
      'any.required': 'Jam manual wajib diisi',
    }),
  manual_reason: Joi.string()
    .max(500)
    .when('attendance_mode', {
      is: 'manual',
      then: Joi.required(),
      otherwise: Joi.optional().allow(null, ''),
    })
    .messages({
      'string.max': 'Alasan maksimal 500 karakter',
      'any.required': 'Alasan absensi manual wajib diisi',
    }),

  notes: Joi.string()
    .max(500)
    .optional()
    .allow(null, '')
    .messages({
      'string.max': 'Catatan maksimal 500 karakter',
    }),

  device_id: Joi.string()
    .max(255)
    .optional()
    .allow(null, ''),

  device_name: Joi.string()
    .max(100)
    .optional()
    .allow(null, ''),
});

export const updateAttendanceSchema = Joi.object({
  status: Joi.string()
    .valid('present', 'late', 'early_leave', 'absent', 'approved', 'rejected')
    .optional()
    .messages({
      'any.only': 'Status tidak valid',
    }),

  notes: Joi.string()
    .max(500)
    .optional()
    .allow(null, ''),

  manual_reason: Joi.string()
    .max(500)
    .optional()
    .allow(null, ''),

  rejection_reason: Joi.string()
    .max(500)
    .optional()
    .allow(null, ''),
});

// =============================================
// Leave Validator
// =============================================
export const createLeaveSchema = Joi.object({
  leave_type_id: Joi.string()
    .uuid()
    .required()
    .messages({
      'string.uuid': 'Format leave_type_id tidak valid',
      'any.required': 'Jenis cuti wajib dipilih',
    }),

  start_date: Joi.date()
    .iso()
    .required()
    .messages({
      'date.iso': 'Format tanggal awal tidak valid',
      'any.required': 'Tanggal awal wajib diisi',
    }),

  end_date: Joi.date()
    .iso()
    .min(Joi.ref('start_date'))
    .required()
    .messages({
      'date.iso': 'Format tanggal akhir tidak valid',
      'date.min': 'Tanggal akhir harus setelah tanggal awal',
      'any.required': 'Tanggal akhir wajib diisi',
    }),

  notes: Joi.string()
    .max(500)
    .optional()
    .allow(null, '')
    .messages({
      'string.max': 'Catatan maksimal 500 karakter',
    }),
});

export const updateLeaveSchema = Joi.object({
  status: Joi.string()
    .valid('approved', 'rejected', 'cancelled')
    .required()
    .messages({
      'any.only': 'Status tidak valid',
      'any.required': 'Status wajib diisi',
    }),

  rejection_reason: Joi.string()
    .max(500)
    .when('status', {
      is: 'rejected',
      then: Joi.required(),
      otherwise: Joi.optional().allow(null, ''),
    })
    .messages({
      'string.max': 'Alasan penolakan maksimal 500 karakter',
      'any.required': 'Alasan penolakan wajib diisi saat menolak',
    }),
});
