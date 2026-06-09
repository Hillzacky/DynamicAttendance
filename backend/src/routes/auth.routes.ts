import { Router } from 'express';
import {
  login,
  logout,
  refreshToken,
  forgotPassword,
  resetPasswordWithToken,
  verifyToken,
} from '@controllers/auth.controller';
import { authenticate } from '@middleware/auth.middleware';
import { validate } from '@validators/user.validator';
import Joi from 'joi';

const router = Router();

// Login schema
const loginSchema = Joi.object({
  username: Joi.string().required().messages({
    'any.required': 'Username wajib diisi',
  }),
  password: Joi.string().required().messages({
    'any.required': 'Password wajib diisi',
  }),
  device_id: Joi.string().optional().allow(null, ''),
  device_name: Joi.string().optional().allow(null, ''),
  device_platform: Joi.string()
    .valid('android', 'ios', 'web')
    .optional()
    .allow(null, ''),
});

// Refresh token schema
const refreshTokenSchema = Joi.object({
  refresh_token: Joi.string().required().messages({
    'any.required': 'Refresh token wajib diisi',
  }),
});

// Forgot password schema
const forgotPasswordSchema = Joi.object({
  email: Joi.string().email().required().messages({
    'string.email': 'Format email tidak valid',
    'any.required': 'Email wajib diisi',
  }),
});

// Reset password schema
const resetPasswordSchema = Joi.object({
  token: Joi.string().required().messages({
    'any.required': 'Token wajib diisi',
  }),
  new_password: Joi.string()
    .min(8)
    .pattern(
      /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/
    )
    .required()
    .messages({
      'string.min': 'Password minimal 8 karakter',
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

// Public routes
router.post('/login', validate(loginSchema), login);
router.post('/refresh-token', validate(refreshTokenSchema), refreshToken);
router.post('/forgot-password', validate(forgotPasswordSchema), forgotPassword);
router.post('/reset-password', validate(resetPasswordSchema), resetPasswordWithToken);

// Protected routes
router.get('/verify', authenticate, verifyToken);
router.post('/logout', authenticate, logout);

export default router;