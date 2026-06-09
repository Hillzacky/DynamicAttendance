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
  formatDate,
  countWorkingDays,
  getDateRange,
} from '@utils/helpers';
import {
  AppError,
  NotFoundError,
} from '@utils/AppError';
import { deleteFile, getFileUrl } from '@utils/upload';
import { logger } from '@utils/logger';
import dayjs from 'dayjs';

// =============================================
// CREATE LEAVE
// =============================================
export const createLeave = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const {
      leave_type_id,
      start_date,
      end_date,
      notes,
    } = req.body;

    const userId = req.user?.id;
    const clientId = req.user?.client_id;

    // Get leave type
    const leaveType = await db('leave_types')
      .where({ id: leave_type_id, is_active: true })
      .first();
    if (!leaveType) throw new NotFoundError('Jenis cuti');

    // Calculate total days
    const totalDays = countWorkingDays(start_date, end_date);

    // Check max days if applicable
    if (leaveType.max_days > 0 && totalDays > leaveType.max_days) {
      throw new AppError(
        `Jenis cuti ${leaveType.name} maksimal ${leaveType.max_days} hari`, 400
      );
    }

    // Check overlapping leave
    const overlapping = await db('leaves')
      .where('user_id', userId)
      .whereNotIn('status', ['rejected', 'cancelled'])
      .where((builder) => {
        builder
          .whereBetween('start_date', [start_date, end_date])
          .orWhereBetween('end_date', [start_date, end_date])
          .orWhere((inner) => {
            inner
              .where('start_date', '<=', start_date)
              .where('end_date', '>=', end_date);
          });
      })
      .first();

    if (overlapping) {
      throw new AppError(
        'Terdapat pengajuan cuti yang tumpang tindih dengan tanggal yang dipilih', 409
      );
    }

    // Check annual leave quota
    if (leaveType.code === 'ANNUAL_LEAVE') {
      const usedDays = await db('leaves')
        .where('user_id', userId)
        .where('leave_type_id', leave_type_id)
        .where('status', 'approved')
        .whereRaw('EXTRACT(YEAR FROM start_date) = ?', [dayjs().year()])
        .sum('total_days as used')
        .first();

      const used = parseInt(usedDays?.used || '0');
      if (used + totalDays > leaveType.max_days) {
        throw new AppError(
          `Kuota cuti tahunan tidak mencukupi. ` +
          `Tersisa: ${leaveType.max_days - used} hari`, 400
        );
      }
    }

    // Document URL
    let documentUrl = null;
    let documentType = null;
    if (req.file) {
      documentUrl = `uploads/leaves/${req.file.filename}`;
      documentType = req.file.mimetype === 'application/pdf'
        ? 'pdf'
        : 'image';
    }
    // Check document required
    if (leaveType.requires_document && !documentUrl) {
      throw new AppError(
        `Jenis cuti ${leaveType.name} memerlukan dokumen pendukung`, 400
      );
    }

    // Create leave
    const [newLeave] = await db('leaves')
      .insert({
        user_id: userId,
        client_id: clientId,
        leave_type_id,
        start_date,
        end_date,
        total_days: totalDays,
        status: 'pending',
        document_url: documentUrl,
        document_type: documentType,
        notes: notes || null,
      })
      .returning('id');

    // Get created leave detail
    const leave = await db('v_leave_detail')
      .where('id', newLeave.id)
      .first();

    logger.info('Leave created', {
      user_id: userId,
      leave_id: newLeave.id,
      leave_type: leaveType.code,
      start_date,
      end_date,
      total_days: totalDays,
    });

    sendCreated(res, leave, 'Pengajuan cuti berhasil dibuat');
  } catch (error) {
    next(error);
  }
};

// =============================================
// GET LEAVES (List)
// =============================================
export const getLeaves = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { page, limit, offset } = parsePagination(req.query);
    const { column, order } = parseSortQuery(
      req.query.sort as string, [
        'start_date', 'end_date', 'total_days',
        'status', 'created_at',
      ]
    );

    const {
      user_id, status, leave_type_id,
      start_date, end_date,
    } = req.query;

    let query = db('v_leave_detail');

    // Filter by role
    if (req.user?.role === 'employee') {
      query = query.where('user_id', req.user.id);
    } else if (req.user?.role !== 'superadmin') {
      query = query.where('client_id', req.user?.client_id);
    }

    // Additional filters
    if (user_id) query = query.where('user_id', user_id);
    if (status) query = query.where('status', status);
    if (leave_type_id) query = query.where('leave_type_id', leave_type_id);

    // Date range
    if (start_date) query = query.where('start_date', '>=', start_date);
    if (end_date) query = query.where('end_date', '<=', end_date);

    // Count total
    const [{ count }] = await query.clone().count('id as count');
    const total = parseInt(count as string);

    // Get data
    const leaves = await query
      .orderBy(column, order)
      .limit(limit)
      .offset(offset);

    sendPaginated(
      res,
      leaves,
      getPaginationMeta(total, page, limit),
      'Data cuti berhasil diambil'
    );
  } catch (error) {
    next(error);
  }
};

// =============================================
// GET LEAVE BY ID
// =============================================
export const getLeaveById = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;

    const leave = await db('v_leave_detail')
      .where('id', id)
      .first();

    if (!leave) throw new NotFoundError('Data cuti');

    // Check access
    if (
      req.user?.role === 'employee' &&
      leave.user_id !== req.user.id
    ) {
      throw new AppError('Akses ditolak', 403);
    }

    sendSuccess(res, leave, 'Detail cuti berhasil diambil');
  } catch (error) {
    next(error);
  }
};

// =============================================
// UPDATE LEAVE STATUS (Approve/Reject)
// =============================================
export const updateLeaveStatus = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const { status, rejection_reason } = req.body;

    const leave = await db('leaves')
      .where('id', id)
      .first();

    if (!leave) throw new NotFoundError('Data cuti');

    // Check if already processed
    if (leave.status !== 'pending') {
      throw new AppError(
        'Pengajuan cuti ini sudah diproses sebelumnya', 400
      );
    }

    // Validate rejection reason
    if (status === 'rejected' && !rejection_reason) {
      throw new AppError(
        'Alasan penolakan wajib diisi', 400
      );
    }

    await db('leaves')
      .where('id', id)
      .update({
        status,
        rejection_reason: rejection_reason || null,
        approved_by: req.user?.id,
        approved_at: db.fn.now(),
        updated_at: db.fn.now(),
      });

    const updatedLeave = await db('v_leave_detail')
      .where('id', id)
      .first();

    logger.info('Leave status updated', {
      leave_id: id,
      status,
      updated_by: req.user?.id,
    });

    sendSuccess(
      res,
      updatedLeave,
      `Pengajuan cuti berhasil ${status === 'approved'
        ? 'disetujui'
        : status === 'rejected'
          ? 'ditolak'
          : 'dibatalkan'
      }`
    );
  } catch (error) {
    next(error);
  }
};

// =============================================
// CANCEL LEAVE (Self)
// =============================================
export const cancelLeave = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const userId = req.user?.id;

    const leave = await db('leaves')
      .where({ id, user_id: userId })
      .first();

    if (!leave) throw new NotFoundError('Data cuti');

    if (!['pending'].includes(leave.status)) {
      throw new AppError(
        'Hanya pengajuan dengan status pending yang dapat dibatalkan', 400
      );
    }

    // Check if leave has started
    if (dayjs().isAfter(dayjs(leave.start_date))) {
      throw new AppError(
        'Tidak dapat membatalkan cuti yang sudah dimulai', 400
      );
    }

    await db('leaves')
      .where('id', id)
      .update({
        status: 'cancelled',
        updated_at: db.fn.now(),
      });

    sendSuccess(res, null, 'Pengajuan cuti berhasil dibatalkan');
  } catch (error) {
    next(error);
  }
};

// =============================================
// GET LEAVE CALENDAR
// =============================================
export const getLeaveCalendar = async (
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

    // Get leaves for month
    const leaves = await db('leaves')
      .where('user_id', targetUserId)
      .whereRaw(
        '(EXTRACT(MONTH FROM start_date) = ? AND EXTRACT(YEAR FROM start_date) = ?) OR ' +
        '(EXTRACT(MONTH FROM end_date) = ? AND EXTRACT(YEAR FROM end_date) = ?)',
        [targetMonth, targetYear, targetMonth, targetYear]
      )
      .join('leave_types', 'leaves.leave_type_id', 'leave_types.id')
      .select(
        'leaves.id',
        'leaves.start_date',
        'leaves.end_date',
        'leaves.total_days',
        'leaves.status',
        'leaves.notes',
        'leaves.document_url',
        'leaves.document_type',
        'leave_types.name as leave_type_name',
        'leave_types.code as leave_type_code',
        'leave_types.is_paid',
      )
      .orderBy('leaves.start_date', 'asc');

    // Build calendar data
    const calendarData: Record<string, any> = {};

    leaves.forEach((leave) => {
      const dates = getDateRange(
        formatDate(leave.start_date),
        formatDate(leave.end_date)
      );

      dates.forEach((date) => {
        const dateMonth = dayjs(date).month() + 1;
        const dateYear = dayjs(date).year();

        if (dateMonth === targetMonth && dateYear === targetYear) {
          calendarData[date] = {
            date,
            leave_id: leave.id,
            leave_type_name: leave.leave_type_name,
            leave_type_code: leave.leave_type_code,
            is_paid: leave.is_paid,
            status: leave.status,
            notes: leave.notes,
            document_url: leave.document_url,
            document_type: leave.document_type,
            start_date: formatDate(leave.start_date),
            end_date: formatDate(leave.end_date),
            total_days: leave.total_days,
          };
        }
      });
    });

    // Get leave quota summary
    const leaveQuota = await db('leave_types')
      .where('is_active', true)
      .where((builder) => {
        builder
          .whereNull('client_id')
          .orWhere('client_id', req.user?.client_id);
      })
      .select(
        'id',
        'name',
        'code',
        'max_days',
        'is_paid',
        'requires_document',
      );

    // Get used days per leave type
    const usedDays = await db('leaves')
      .where('user_id', targetUserId)
      .where('status', 'approved')
      .whereRaw('EXTRACT(YEAR FROM start_date) = ?', [targetYear])
      .groupBy('leave_type_id')
      .select(
        'leave_type_id',
        db.raw('SUM(total_days) as used_days')
      );
    // Merge quota with used days
    const usedDaysMap = usedDays.reduce((acc: any, curr: any) => {
      acc[curr.leave_type_id] = parseInt(curr.used_days || '0');
      return acc;
    }, {});

    const quotaSummary = leaveQuota.map((lt: any) => ({
      leave_type_id: lt.id,
      leave_type_name: lt.name,
      leave_type_code: lt.code,
      max_days: lt.max_days,
      used_days: usedDaysMap[lt.id] || 0,
      remaining_days: lt.max_days > 0
        ? lt.max_days - (usedDaysMap[lt.id] || 0)
        : null,
      is_paid: lt.is_paid,
      requires_document: lt.requires_document,
    }));

    sendSuccess(res, {
      calendar: calendarData,
      quota_summary: quotaSummary,
      month: targetMonth,
      year: targetYear,
    }, 'Kalender cuti berhasil diambil');
  } catch (error) {
    next(error);
  }
};

// =============================================
// GET LEAVE TYPES
// =============================================
export const getLeaveTypes = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const clientId = req.user?.client_id;

    const leaveTypes = await db('leave_types')
      .where('is_active', true)
      .where((builder) => {
        builder
          .whereNull('client_id')
          .orWhere('client_id', clientId);
      })
      .select(
        'id', 'name', 'code',
        'max_days', 'is_paid',
        'requires_document',
      )
      .orderBy('name', 'asc');

    sendSuccess(res, leaveTypes, 'Jenis cuti berhasil diambil');
  } catch (error) {
    next(error);
  }
};

// =============================================
// DELETE LEAVE (Admin)
// =============================================
export const deleteLeave = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;

    const leave = await db('leaves')
      .where('id', id)
      .first();

    if (!leave) throw new NotFoundError('Data cuti');

    // Delete document if exists
    if (leave.document_url) {
      deleteFile(leave.document_url);
    }

    await db('leaves')
      .where('id', id)
      .delete();

    logger.info('Leave deleted', {
      leave_id: id,
      deleted_by: req.user?.id,
    });

    sendSuccess(res, null, 'Data cuti berhasil dihapus');
  } catch (error) {
    next(error);
  }
};