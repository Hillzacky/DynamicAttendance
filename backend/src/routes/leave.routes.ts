import { Router } from 'express';
import {
  createLeave,
  getLeaves,
  getLeaveById,
  updateLeaveStatus,
  cancelLeave,
  getLeaveCalendar,
  getLeaveTypes,
  deleteLeave,
} from '@controllers/leave.controller';
import {
  authenticate,
  authorize,
} from '@middleware/auth.middleware';
import {
  createLeaveSchema,
  updateLeaveSchema,
  validate,
} from '@validators/attendance.validator';
import { uploadLeaveDocument } from '@utils/upload';

const router = Router();

// Apply authentication
router.use(authenticate);

// Upload middleware wrapper
const uploadDocMiddleware = (req: any, res: any, next: any) => {
  uploadLeaveDocument(req, res, (err) => {
    if (err) return next(err);
    next();
  });
};

// =============================================
// Employee Routes
// =============================================
router.get('/types', getLeaveTypes);
router.get('/calendar', getLeaveCalendar);

router.post('/',
  uploadDocMiddleware,
  validate(createLeaveSchema),
  createLeave
);

router.get('/:id', getLeaveById);
router.put('/:id/cancel', cancelLeave);

// =============================================
// Admin Routes
// =============================================
router.get('/',
  authorize('superadmin', 'admin', 'hr'),
  getLeaves
);

router.put('/:id/status',
  authorize('superadmin', 'admin', 'hr'),
  validate(updateLeaveSchema),
  updateLeaveStatus
);

router.delete('/:id',
  authorize('superadmin', 'admin'),
  deleteLeave
);

export default router;