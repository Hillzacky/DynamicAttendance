import Joi from 'joi';

export const createUserSchema = Joi.object({
  username: Joi.string()
    .alphanum()
    .min(3)
    .max(50)
    .required()
    .messages({
      'string.alphanum': 'Username hanya boleh berisi huruf dan angka',
      'string.min': 'Username minimal 3 karakter',
      'string.max': 'Username maksimal 50 karakter',
      'any.required': 'Username wajib diisi',
    }),

  password: Joi.string()
    .min(8)
    .max(100)
    .pattern(
      /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/
    )
    .required()
    .messages({
      'string.min': 'Password minimal 8 karakter',
      'string.pattern.base':
        'Password harus mengandung huruf besar, kecil, angka, dan karakter spesial',
      'any.required': 'Password wajib diisi',
    }),
  fullname: Joi.string()
    .min(3)
    .max(150)
    .required()
    .messages({
      'string.min': 'Nama lengkap minimal 3 karakter',
      'string.max': 'Nama lengkap maksimal 150 karakter',
      'any.required': 'Nama lengkap wajib diisi',
    }),

  email: Joi.string()
    .email()
    .max(100)
    .required()
    .messages({
      'string.email': 'Format email tidak valid',
      'string.max': 'Email maksimal 100 karakter',
      'any.required': 'Email wajib diisi',
    }),

  kontak: Joi.string()
    .pattern(/^[0-9+\-\s()]+$/)
    .min(8)
    .max(20)
    .optional()
    .messages({
      'string.pattern.base': 'Format nomor kontak tidak valid',
      'string.min': 'Nomor kontak minimal 8 karakter',
    }),

  nip: Joi.string()
    .max(50)
    .optional()
    .allow(null, '')
    .messages({
      'string.max': 'NIP maksimal 50 karakter',
    }),

  client_id: Joi.string()
    .uuid()
    .required()
    .messages({
      'string.uuid': 'Format client_id tidak valid',
      'any.required': 'Client wajib dipilih',
    }),

  department_id: Joi.string()
    .uuid()
    .optional()
    .allow(null, '')
    .messages({
      'string.uuid': 'Format department_id tidak valid',
    }),

  position_id: Joi.string()
    .uuid()
    .optional()
    .allow(null, '')
    .messages({
      'string.uuid': 'Format position_id tidak valid',
    }),

  no_bpjs: Joi.string()
    .max(50)
    .optional()
    .allow(null, '')
    .messages({
      'string.max': 'No BPJS maksimal 50 karakter',
    }),

  no_jmo: Joi.string()
    .max(50)
    .optional()
    .allow(null, '')
    .messages({
      'string.max': 'No JMO maksimal 50 karakter',
    }),

  status: Joi.string()
    .valid('active', 'inactive', 'suspended', 'resigned')
    .default('active')
    .messages({
      'any.only': 'Status tidak valid',
    }),

  role: Joi.string()
    .valid('superadmin', 'admin', 'hr', 'employee')
    .default('employee')
    .messages({
      'any.only': 'Role tidak valid',
    }),
});

export const updateUserSchema = Joi.object({
  username: Joi.string()
    .alphanum()
    .min(3)
    .max(50)
    .optional()
    .messages({
      'string.alphanum': 'Username hanya boleh berisi huruf dan angka',
      'string.min': 'Username minimal 3 karakter',
    }),

  fullname: Joi.string()
    .min(3)
    .max(150)
    .optional()
    .messages({
      'string.min': 'Nama lengkap minimal 3 karakter',
    }),

  email: Joi.string()
    .email()
    .max(100)
    .optional()
    .messages({
      'string.email': 'Format email tidak valid',
    }),
  kontak: Joi.string()
    .pattern(/^[0-9+\-\s()]+$/)
    .min(8)
    .max(20)
    .optional()
    .allow(null, '')
    .messages({
      'string.pattern.base': 'Format nomor kontak tidak valid',
    }),

  nip: Joi.string()
    .max(50)
    .optional()
    .allow(null, '')
    .messages({
      'string.max': 'NIP maksimal 50 karakter',
    }),

  department_id: Joi.string()
    .uuid()
    .optional()
    .allow(null, '')
    .messages({
      'string.uuid': 'Format department_id tidak valid',
    }),

  position_id: Joi.string()
    .uuid()
    .optional()
    .allow(null, '')
    .messages({
      'string.uuid': 'Format position_id tidak valid',
    }),

  no_bpjs: Joi.string()
    .max(50)
    .optional()
    .allow(null, '')
    .messages({
      'string.max': 'No BPJS maksimal 50 karakter',
    }),

  no_jmo: Joi.string()
    .max(50)
    .optional()
    .allow(null, '')
    .messages({
      'string.max': 'No JMO maksimal 50 karakter',
    }),

  status: Joi.string()
    .valid('active', 'inactive', 'suspended', 'resigned')
    .optional()
    .messages({
      'any.only': 'Status tidak valid',
    }),

  role: Joi.string()
    .valid('superadmin', 'admin', 'hr', 'employee')
    .optional()
    .messages({
      'any.only': 'Role tidak valid',
    }),
});

export const changePasswordSchema = Joi.object({
  old_password: Joi.string()
    .required()
    .messages({
      'any.required': 'Password lama wajib diisi',
    }),

  new_password: Joi.string()
    .min(8)
    .max(100)
    .pattern(
      /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/
    )
    .required()
    .messages({
      'string.min': 'Password baru minimal 8 karakter',
      'string.pattern.base':
        'Password harus mengandung huruf besar, kecil, angka, dan karakter spesial',
      'any.required': 'Password baru wajib diisi',
    }),

  confirm_password: Joi.string()
    .valid(Joi.ref('new_password'))
    .required()
    .messages({
      'any.only': 'Konfirmasi password tidak cocok',
      'any.required': 'Konfirmasi password wajib diisi',
    }),
});

// =============================================
// Validate Middleware Helper
// =============================================
export const validate = (schema: Joi.ObjectSchema) => {
  return (req: any, res: any, next: any) => {
    const { error, value } = schema.validate(req.body, {
      abortEarly: false,
      stripUnknown: true,
    });

    if (error) {
      const errors: Record<string, string[]> = {};
      error.details.forEach((detail) => {
        const key = detail.path.join('.');
        if (!errors[key]) errors[key] = [];
        errors[key].push(detail.message);
      });

      return res.status(422).json({
        status: 'error',
        statusCode: 422,
        message: 'Validasi gagal',
        errors,
      });
    }

    req.body = value;
    next();
  };
};