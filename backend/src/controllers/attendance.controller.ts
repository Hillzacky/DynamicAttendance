import { Request, Response, NextFunction } from 'express';
import { db } from '@config/database';
import {
  sendSuccess,
  sendCreated,
  sendPaginated,
  getPaginationMeta,
  parsePagination,
  parseSortQuery,
} from '@utils/response';
import {
  calculateDistance,
  isWithinRadius,
  formatDate,
  formatDateTime,
} from '@utils/helpers';
import {
  AppError,
  NotFoundError,
} from '@utils/AppError';
import { deleteFile, getFileUrl } from '@utils/upload';
import { logger } from '@utils/logger';
import dayjs from 'dayjs';

// =============================================
// CREATE ATTENDANCE (Current)
// =============================================
export const createAttendance = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const {
      location_id, shift_id, type,
      attendance_mode, employee_latitude,
      employee_longitude, notes,
      device_id, device_name,
    } = req.body;

    const userId = req.user?.id;
    const clientId = req.user?.client_id;
    const today = formatDate(new Date());

    // Get location detail
    const location = await db('locations')
      .where({ id: location_id, is_active: true })
      .first();

    if (!location) throw new NotFoundError('Lokasi');

    // Check duplicate attendance
    const existingAttendance = await db('attendances')
      .where({
        user_id: userId,
        attendance_date: today,
        type,
        attendance_mode: 'current',
      })
      .first();

    if (existingAttendance) {
      throw new AppError(
        `Anda sudah melakukan ${type === 'check_in'
          ? 'absen masuk'
          : 'absen keluar'} hari ini`, 409
      );
    }

    // Calculate distance
    let distanceMeter = 0;
    let withinRadius = false;

    if (attendance_mode === 'current') {
      distanceMeter = calculateDistance(
        employee_latitude,
        employee_longitude,
        location.latitude,
        location.longitude
      );
      withinRadius = isWithinRadius(distanceMeter, location.radius);

      if (!withinRadius) {
        throw new AppError(
          `Anda berada di luar jangkauan absensi. ` +
          `Jarak Anda: ${distanceMeter}m, ` +
          `Jangkauan: ${location.radius}m`, 400
        );
      }
    }

    // Determine attendance status
    const shift = await db('shifts')
      .where({ id: shift_id })
      .first();

    let attendanceStatus = 'present';
    const now = dayjs();

    if (type === 'check_in' && shift) {
      const checkInTime = dayjs(
        `${today} ${shift.check_in_time}`
      );
      const lateThreshold = checkInTime.add(
        shift.late_tolerance, 'minute'
      );
      if (now.isAfter(lateThreshold)) {
        attendanceStatus = 'late';
      }
    }

    if (type === 'check_out' && shift) {
      const checkOutTime = dayjs(
        `${today} ${shift.check_out_time}`
      );
      const earlyThreshold = checkOutTime.subtract(
        shift.early_leave_tolerance, 'minute'
      );
      if (now.isBefore(earlyThreshold)) {
        attendanceStatus = 'early_leave';
      }
    }

    // Photo URL
    let photoUrl = null;
    if (req.file) {
      photoUrl = `uploads/attendance/${req.file.filename}`;
    }

    // Create attendance
    const [newAttendance] = await db('attendances')
      .insert({
        user_id: userId,
        client_id: clientId,
        location_id,
        shift_id,
        attendance_date: today,
        type,
        attendance_mode: attendance_mode || 'current',
        attendance_time: db.fn.now(),
        photo_url: photoUrl,
        employee_latitude,
        employee_longitude,
        office_latitude: location.latitude,
        office_longitude: location.longitude,
        distance_meter: distanceMeter,
        radius_meter: location.radius,
        is_within_radius: withinRadius,
        status: attendanceStatus,
        notes: notes || null,
        device_id: device_id || null,
        device_name: device_name || null,
      })
      .returning('id');

    // Get created attendance detail
    const attendance = await db('v_attendance_detail')
      .where('id', newAttendance.id)
      .first();

    logger.info('Attendance created', {
      user_id: userId,
      attendance_id: newAttendance.id,
      type,
      status: attendanceStatus,
      distance: distanceMeter,
    });

    sendCreated(res, attendance, 'Absensi berhasil ditambahkan');
  } catch (error) {
    next(error);
  }
};

// =============================================
// CREATE MANUAL ATTENDANCE
// =============================================
export const createManualAttendance = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const {
      location_id, shift_id, type,
      manual_date, manual_time,
      manual_reason, notes,
      device_id, device_name,
    } = req.body;

    const userId = req.user?.id;
    const clientId = req.user?.client_id;

    // Get location detail
    const location = await db('locations')
      .where({ id: location_id, is_active: true })
      .first();
    if (!location) throw new NotFoundError('Lokasi');

    // Check duplicate manual attendance
    const existingAttendance = await db('attendances')
      .where({
        user_id: userId,
        attendance_date: manual_date,
        type,
        attendance_mode: 'manual',
      })
      .first();

    if (existingAttendance) {
      throw new AppError(
        `Absensi manual ${type === 'check_in'
          ? 'masuk'
          : 'keluar'} untuk tanggal ini sudah ada`, 409
      );
    }

    // Photo URL
    let photoUrl = null;
    if (req.file) {
      photoUrl = `uploads/attendance/${req.file.filename}`;
    }

    // Create manual attendance
    const [newAttendance] = await db('attendances')
      .insert({
        user_id: userId,
        client_id: clientId,
        location_id,
        shift_id,
        attendance_date: manual_date,
        type,
        attendance_mode: 'manual',
        attendance_time: `${manual_date} ${manual_time}`,
        photo_url: photoUrl,
        office_latitude: location.latitude,
        office_longitude: location.longitude,
        distance_meter: 0,
        radius_meter: location.radius,
        is_within_radius: true,
        status: 'pending',
        manual_date,
        manual_time,
        manual_reason,
        notes: notes || null,
        device_id: device_id || null,
        device_name: device_name || null,
      })
      .returning('id');

    // Get created attendance detail
    const attendance = await db('v_attendance_detail')
      .where('id', newAttendance.id)
      .first();

    logger.info('Manual attendance created', {
      user_id: userId,
      attendance_id: newAttendance.id,
      type,
      manual_date,
      manual_time,
    });

    sendCreated(res, attendance, 'Absensi manual berhasil ditambahkan');
  } catch (error) {
    next(error);
  }
};

// =============================================
// GET ATTENDANCES (List)
// =============================================
export const getAttendances = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { page, limit, offset } = parsePagination(req.query);
    const { column, order } = parseSortQuery(
      req.query.sort as string, [
        'attendance_date', 'attendance_time',
        'type', 'status', 'created_at',
      ]
    );

    const {
      user_id, type, status, attendance_mode,
      start_date, end_date, location_id, shift_id,
    } = req.query;

    let query = db('v_attendance_detail');

    // Filter by role
    if (req.user?.role === 'employee') {
      query = query.where('user_id', req.user.id);
    } else if (req.user?.role !== 'superadmin') {
      query = query.where('client_id', req.user?.client_id);
    }

    // Additional filters
    if (user_id) query = query.where('user_id', user_id);
    if (type) query = query.where('type', type);
    if (status) query = query.where('status', status);
    if (attendance_mode) query = query.where('attendance_mode', attendance_mode);
    if (location_id) query = query.where('location_id', location_id);
    if (shift_id) query = query.where('shift_id', shift_id);

    // Date range filter
    if (start_date) {
      query = query.where('attendance_date', '>=', start_date);
    }
    if (end_date) {
      query = query.where('attendance_date', '<=', end_date);
    }

    // Count total
    const [{ count }] = await query.clone().count('id as count');
    const total = parseInt(count as string);

    // Get data
    const attendances = await query
      .orderBy(column, order)
      .limit(limit)
      .offset(offset);

    sendPaginated(
      res,
      attendances,
      getPaginationMeta(total, page, limit),
      'Data absensi berhasil diambil'
    );
  } catch (error) {
    next(error);
  }
};

// =============================================
// GET ATTENDANCE BY ID
// =============================================
export const getAttendanceById = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;

    const attendance = await db('v_attendance_detail')
      .where('id', id)
      .first();

    if (!attendance) throw new NotFoundError('Absensi');

    // Check access
    if (
      req.user?.role === 'employee' &&
      attendance.user_id !== req.user.id
    ) {
      throw new AppError('Akses ditolak', 403);
    }

    sendSuccess(res, attendance, 'Detail absensi berhasil diambil');
  } catch (error) {
    next(error);
  }
};

// =============================================
// GET ATTENDANCE CALENDAR
// =============================================
export const getAttendanceCalendar = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { month, year, user_id, attendance_mode } = req.query;

    const targetUserId = req.user?.role === 'employee'
      ? req.user.id
      : (user_id || req.user?.id);

    const targetMonth = parseInt(month as string) || dayjs().month() + 1;
    const targetYear = parseInt(year as string) || dayjs().year();

    // Get attendances for month
    const attendances = await db('attendances')
      .where('user_id', targetUserId)
      .whereRaw(
        'EXTRACT(MONTH FROM attendance_date) = ?', [targetMonth]
      )
      .whereRaw(
        'EXTRACT(YEAR FROM attendance_date) = ?', [targetYear]
      )
      .modify((builder) => {
        if (attendance_mode) {
          builder.where('attendance_mode', attendance_mode);
        }
      })
      .select(
        'id',
        'attendance_date',
        'type',
        'attendance_mode',
        'attendance_time',
        'status',
        'photo_url',
        'notes',
        'distance_meter',
        'is_within_radius',
      )
      .orderBy('attendance_date', 'asc')
      .orderBy('attendance_time', 'asc');

    // Group by date
    const calendarData: Record<string, any> = {};

    attendances.forEach((att) => {
      const dateKey = formatDate(att.attendance_date);
      if (!calendarData[dateKey]) {
        calendarData[dateKey] = {
          date: dateKey,
          check_in: null,
          check_out: null,
          status: null,
          has_attendance: false,
        };
      }

      if (att.type === 'check_in') {
        calendarData[dateKey].check_in = {
          id: att.id,
          time: formatDateTime(att.attendance_time, 'HH:mm:ss'),
          status: att.status,
          photo_url: att.photo_url,
          notes: att.notes,
          distance_meter: att.distance_meter,
          is_within_radius: att.is_within_radius,
        };
        calendarData[dateKey].status = att.status;
        calendarData[dateKey].has_attendance = true;
      }

      if (att.type === 'check_out') {
        calendarData[dateKey].check_out = {
          id: att.id,
          time: formatDateTime(att.attendance_time, 'HH:mm:ss'),
          status: att.status,
          photo_url: att.photo_url,
          notes: att.notes,
          distance_meter: att.distance_meter,
          is_within_radius: att.is_within_radius,
        };
      }
    });

    // Get leave data for month
    const leaves = await db('leaves')
      .where('user_id', targetUserId)
      .where('status', 'approved')
      .whereRaw(
        'EXTRACT(MONTH FROM start_date) = ? OR EXTRACT(MONTH FROM end_date) = ?',
        [targetMonth, targetMonth]
      )
      .whereRaw(
        'EXTRACT(YEAR FROM start_date) = ? OR EXTRACT(YEAR FROM end_date) = ?',
        [targetYear, targetYear]
      )
      .join('leave_types', 'leaves.leave_type_id', 'leave_types.id')
      .select(
        'leaves.id',
        'leaves.start_date',
        'leaves.end_date',
        'leaves.status',
        'leaves.notes',
        'leave_types.name as leave_type_name',
        'leave_types.code as leave_type_code',
      );

    // Add leave data to calendar
    leaves.forEach((leave) => {
      const dates = getDateRange(
        formatDate(leave.start_date),
        formatDate(leave.end_date)
      );

      dates.forEach((date) => {
        const dateMonth = dayjs(date).month() + 1;
        const dateYear = dayjs(date).year();

        if (dateMonth === targetMonth && dateYear === targetYear) {
          if (!calendarData[date]) {
            calendarData[date] = {
              date,
              check_in: null,
              check_out: null,
              status: null,
              has_attendance: false,
            };
          }
          calendarData[date].leave = {
            id: leave.id,
            leave_type_name: leave.leave_type_name,
            leave_type_code: leave.leave_type_code,
            status: leave.status,
            notes: leave.notes,
          };
          calendarData[date].status = leave.leave_type_code;
        }
      });
    });

    // Get attendance summary
    const summary = await db.raw(
      'SELECT * FROM get_attendance_summary(?, ?, ?)',
      [targetUserId, targetMonth, targetYear]
    );

    sendSuccess(res, {
      calendar: calendarData,
      summary: summary.rows,
      month: targetMonth,
      year: targetYear,
    }, 'Kalender absensi berhasil diambil');
  } catch (error) {
    next(error);
  }
};

// =============================================
// APPROVE / REJECT MANUAL ATTENDANCE
// =============================================
export const updateAttendanceStatus = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const { status, rejection_reason } = req.body;

    const attendance = await db('attendances')
      .where('id', id)
      .first();

    if (!attendance) throw new NotFoundError('Absensi');

    if (attendance.attendance_mode !== 'manual') {
      throw new AppError(
        'Hanya absensi manual yang dapat diapprove/reject', 400
      );
    }

    if (attendance.status !== 'pending') {
      throw new AppError(
        'Absensi ini sudah diproses sebelumnya', 400
      );
    }

    await db('attendances')
      .where('id', id)
      .update({
        status,
        approved_by: req.user?.id,
        approved_at: db.fn.now(),
        manual_reason: rejection_reason || attendance.manual_reason,
        updated_at: db.fn.now(),
      });

    const updatedAttendance = await db('v_attendance_detail')
      .where('id', id)
      .first();

    logger.info('Attendance status updated', {
      attendance_id: id,
      status,
      updated_by: req.user?.id,
    });

    sendSuccess(
      res,
      updatedAttendance,
      `Absensi berhasil ${status === 'approved' ? 'disetujui' : 'ditolak'}`
    );
  } catch (error) {
    next(error);
  }
};
// =============================================
// GET TODAY ATTENDANCE
// =============================================
export const getTodayAttendance = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.id;
    const today = formatDate(new Date());

    const attendances = await db('v_attendance_detail')
      .where('user_id', userId)
      .where('attendance_date', today)
      .orderBy('attendance_time', 'asc');

    const checkIn = attendances.find((a) => a.type === 'check_in');
    const checkOut = attendances.find((a) => a.type === 'check_out');

    // Calculate work duration
    let workDuration = null;
    if (checkIn && checkOut) {
      const checkInTime = dayjs(checkIn.attendance_time);
      const checkOutTime = dayjs(checkOut.attendance_time);
      const diffMinutes = checkOutTime.diff(checkInTime, 'minute');
      const hours = Math.floor(diffMinutes / 60);
      const minutes = diffMinutes % 60;
      workDuration = {
        hours,
        minutes,
        formatted: `${hours}j ${minutes}m`,
        total_minutes: diffMinutes,
      };
    }

    // Get user shifts
    const userShift = await db('user_shifts')
      .where('user_id', userId)
      .where('is_active', true)
      .where('effective_date', '<=', today)
      .where((builder) => {
        builder
          .whereNull('end_date')
          .orWhere('end_date', '>=', today);
      })
      .join('shifts', 'user_shifts.shift_id', 'shifts.id')
      .select(
        'shifts.id',
        'shifts.name',
        'shifts.check_in_time',
        'shifts.check_out_time',
        'shifts.late_tolerance',
        'shifts.early_leave_tolerance',
        'shifts.is_overnight',
      )
      .first();

    // Get user locations
    const userLocations = await db('user_locations')
      .where('user_id', userId)
      .where('is_active', true)
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

    sendSuccess(res, {
      date: today,
      check_in: checkIn || null,
      check_out: checkOut || null,
      work_duration: workDuration,
      can_check_in: !checkIn,
      can_check_out: checkIn && !checkOut,
      shift: userShift || null,
      locations: userLocations,
    }, 'Data absensi hari ini berhasil diambil');
  } catch (error) {
    next(error);
  }
};

// =============================================
// GET ATTENDANCE STATISTICS
// =============================================
export const getAttendanceStatistics = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { month, year, user_id } = req.query;

    const targetUserId = req.user?.role === 'employee'
      ? req.user.id
      : (user_id || req.user?.id);

    const targetMonth = parseInt(month as string) || dayjs().month() + 1;
    const targetYear = parseInt(year as string) || dayjs().year();

    // Get summary from function
    const summaryResult = await db.raw(
      'SELECT * FROM get_attendance_summary(?, ?, ?)',
      [targetUserId, targetMonth, targetYear]
    );
    const summary = summaryResult.rows;

    // Get attendance by status
    const attendanceByStatus = await db('attendances')
      .where('user_id', targetUserId)
      .where('type', 'check_in')
      .whereRaw('EXTRACT(MONTH FROM attendance_date) = ?', [targetMonth])
      .whereRaw('EXTRACT(YEAR FROM attendance_date) = ?', [targetYear])
      .groupBy('status')
      .select(
        'status',
        db.raw('COUNT(*) as total')
      );

    // Get late arrivals detail
    const lateArrivals = await db('v_attendance_detail')
      .where('user_id', targetUserId)
      .where('type', 'check_in')
      .where('status', 'late')
      .whereRaw('EXTRACT(MONTH FROM attendance_date) = ?', [targetMonth])
      .whereRaw('EXTRACT(YEAR FROM attendance_date) = ?', [targetYear])
      .select(
        'attendance_date',
        'attendance_time',
        'check_in_time',
        'shift_name',
        'location_name',
      )
      .orderBy('attendance_date', 'asc');

    // Get early leaves detail
    const earlyLeaves = await db('v_attendance_detail')
      .where('user_id', targetUserId)
      .where('type', 'check_out')
      .where('status', 'early_leave')
      .whereRaw('EXTRACT(MONTH FROM attendance_date) = ?', [targetMonth])
      .whereRaw('EXTRACT(YEAR FROM attendance_date) = ?', [targetYear])
      .select(
        'attendance_date',
        'attendance_time',
        'check_out_time',
        'shift_name',
        'location_name',
      )
      .orderBy('attendance_date', 'asc');

    // Get leave summary
    const leaveSummary = await db('leaves')
      .where('user_id', targetUserId)
      .where('status', 'approved')
      .whereRaw('EXTRACT(MONTH FROM start_date) = ?', [targetMonth])
      .whereRaw('EXTRACT(YEAR FROM start_date) = ?', [targetYear])
      .join('leave_types', 'leaves.leave_type_id', 'leave_types.id')
      .groupBy('leave_types.name', 'leave_types.code')
      .select(
        'leave_types.name as leave_type_name',
        'leave_types.code as leave_type_code',
        db.raw('COUNT(*) as total_requests'),
        db.raw('SUM(total_days) as total_days'),
      );

    sendSuccess(res, {
      month: targetMonth,
      year: targetYear,
      summary: {
        ...summary,
        attendance_rate: summary.total_working_days > 0
          ? Math.round(
            (summary.total_present / summary.total_working_days) * 100
          )
          : 0,
      },
      attendance_by_status: attendanceByStatus,
      late_arrivals: lateArrivals,
      early_leaves: earlyLeaves,
      leave_summary: leaveSummary,
    }, 'Statistik absensi berhasil diambil');
  } catch (error) {
    next(error);
  }
};