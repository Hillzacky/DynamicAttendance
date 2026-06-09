import { Response } from 'express';

interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
  hasNext: boolean;
  hasPrev: boolean;
}

export const sendSuccess = (
  res: Response,
  data: any,
  message: string = 'Berhasil',
  statusCode: number = 200
): Response => {
  return res.status(statusCode).json({
    status: 'success',
    statusCode,
    message,
    data,
  });
};
export const sendPaginated = (
  res: Response,
  data: any[],
  meta: PaginationMeta,
  message: string = 'Berhasil',
  statusCode: number = 200
): Response => {
  return res.status(statusCode).json({
    status: 'success',
    statusCode,
    message,
    data,
    meta: {
      page: meta.page,
      limit: meta.limit,
      total: meta.total,
      totalPages: meta.totalPages,
      hasNext: meta.hasNext,
      hasPrev: meta.hasPrev,
    },
  });
};

export const sendError = (
  res: Response,
  message: string = 'Terjadi kesalahan',
  statusCode: number = 500,
  errors?: Record<string, string[]>
): Response => {
  return res.status(statusCode).json({
    status: 'error',
    statusCode,
    message,
    ...(errors && { errors }),
  });
};

export const sendCreated = (
  res: Response,
  data: any,
  message: string = 'Data berhasil dibuat'
): Response => {
  return sendSuccess(res, data, message, 201);
};

export const sendNoContent = (res: Response): Response => {
  return res.status(204).send();
};

// Pagination Helper
export const getPaginationMeta = (
  total: number,
  page: number,
  limit: number
): PaginationMeta => {
  const totalPages = Math.ceil(total / limit);
  return {
    page,
    limit,
    total,
    totalPages,
    hasNext: page < totalPages,
    hasPrev: page > 1,
  };
};

// Parse Pagination Query
export const parsePagination = (query: any): {
  page: number;
  limit: number;
  offset: number;
} => {
  const page = Math.max(1, parseInt(query.page) || 1);
  const limit = Math.min(100, Math.max(1, parseInt(query.limit) || 10));
  const offset = (page - 1) * limit;
  return { page, limit, offset };
};