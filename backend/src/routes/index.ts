import { Router } from 'express';
import authRoutes from './auth.routes';
import userRoutes from './user.routes';
import attendanceRoutes from './attendance.routes';
import leaveRoutes from './leave.routes';
import locationRoutes from './location.routes';
import shiftRoutes from './shift.routes';
import clientRoutes from './client.routes';
import departmentRoutes from './department.routes';

const router = Router();

router.use('/auth', authRoutes);
router.use('/users', userRoutes);
router.use('/attendances', attendanceRoutes);
router.use('/leaves', leaveRoutes);
router.use('/locations', locationRoutes);
router.use('/shifts', shiftRoutes);
router.use('/clients', clientRoutes);
router.use('/departments', departmentRoutes);

export default router;