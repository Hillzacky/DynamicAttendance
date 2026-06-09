import { Router } from 'express';
import {
  getUsers,
  getUserById,
  createUser,
  updateUser,
  deleteUser,
  uploadUserAvatar,
  changePassword,
  resetPassword,
  getProfile,
  updateProfile,
  updateDeviceInfo,
  getUserStatistics,
} from '@controllers/user.controller';
import {
  authenticate,
  authorize,
  sameClient,
} from '@middleware/auth.middleware';
import {
  createUserSchema,
  updateUserSchema,
  changePasswordSchema,
  validate,
} from '@validators/user.validator';
import { uploadAvatar } from '@utils/upload';

const router = Router();

// Apply authentication to all routes
router.use(authenticate);

// =============================================
// Profile Routes (Self)
// =============================================
router.get('/profile', getProfile);
router.put('/profile', validate(updateUserSchema), updateProfile);
router.post('/profile/avatar',
  (req, res, next) => {
    uploadAvatar(req, res, (err) => {
      if (err) return next(err);
      next();
    });
  },
  uploadUserAvatar
);
router.put('/profile/device', updateDeviceInfo);
router.put('/profile/change-password',
  validate(changePasswordSchema),
  changePassword
);

// =============================================
// Admin Routes
// =============================================
router.get('/',
  authorize('superadmin', 'admin', 'hr'),
  getUsers
);

router.get('/statistics',
  authorize('superadmin', 'admin', 'hr'),
  getUserStatistics
);

router.get('/:id',
  authorize('superadmin', 'admin', 'hr'),
  getUserById
);

router.post('/',
  authorize('superadmin', 'admin'),
  validate(createUserSchema),
  createUser
);

router.put('/:id',
  authorize('superadmin', 'admin'),
  validate(updateUserSchema),
  updateUser
);

router.delete('/:id',
  authorize('superadmin', 'admin'),
  deleteUser
);

router.post('/:id/avatar',
  authorize('superadmin', 'admin'),
  (req, res, next) => {
    uploadAvatar(req, res, (err) => {
      if (err) return next(err);
      next();
    });
  },
  uploadUserAvatar
);

router.put('/:id/change-password',
  authorize('superadmin', 'admin'),
  validate(changePasswordSchema),
  changePassword
);

router.put('/:id/reset-password',
  authorize('superadmin', 'admin'),
  resetPassword
);

export default router;