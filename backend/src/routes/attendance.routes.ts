import { Router } from 'express';
import {
  createAttendance,
  createManualAttendance,
  getAttendances,
  getAttendanceById,
  getAttendanceCalendar,
  updateAttendanceStatus,
  getTodayAttendance,
  getAttendanceStatistics,
} from '@controllers/attendance.controller';
import {
  authenticate,
  authorize,
} from '@middleware/auth.middleware';
import {
  createAttendanceSchema,
  updateAttendanceSchema,
  validate,
} from '@validators/attendance.validator';
import { uploadAttendancePhoto } from '@utils/upload';

const router = Router();

// Apply authentication
router.use(authenticate);

// Upload middleware wrapper
const uploadPhotoMiddleware = (req: any, res: any, next: any) => {
  uploadAttendancePhoto(req, res, (err) => {
    if (err) return next(err);
    next();
  });
};

// =============================================
// Employee Routes
// =============================================
router.get('/today', getTodayAttendance);
router.get('/calendar', getAttendanceCalendar);
router.get('/statistics', getAttendanceStatistics);

router.post('/',
  uploadPhotoMiddleware,
  validate(createAttendanceSchema),
  createAttendance
);

router.post('/manual',
  uploadPhotoMiddleware,
  validate(createAttendanceSchema),
  createManualAttendance
);

router.get('/:id', getAttendanceById);

// =============================================
// Admin Routes
// =============================================
router.get('/',
  authorize('superadmin', 'admin', 'hr'),
  getAttendances
);

router.put('/:id/status',
  authorize('superadmin', 'admin', 'hr'),
  validate(updateAttendanceSchema),
  updateAttendanceStatus
);

export default router;