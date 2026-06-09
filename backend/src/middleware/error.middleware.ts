import { Request, Response, NextFunction } from 'express';
import { AppError } from '@utils/AppError';
import { logger } from '@utils/logger';

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  if (err instanceof AppError) {
    res.status(err.statusCode).json({
      status: 'error',
      statusCode: err.statusCode,
      message: err.message,
      ...(process.env.NODE_ENV === 'development' && {
        stack: err.stack,
      }),
    });
    return;
  }

  // PostgreSQL Errors
  if ((err as any).code) {
    const pgError = err as any;
    switch (pgError.code) {
      case '23505': // unique violation
        res.status(409).json({
          status: 'error',
          statusCode: 409,
          message: 'Data sudah ada, tidak dapat duplikasi',
          detail: pgError.detail,
        });
        return;
      case '23503': // foreign key violation
        res.status(400).json({
          status: 'error',
          statusCode: 400,
          message: 'Referensi data tidak valid',
          detail: pgError.detail,
        });
        return;
      case '23502': // not null violation
        res.status(400).json({
          status: 'error',
          statusCode: 400,
          message: 'Field wajib tidak boleh kosong',
          detail: pgError.detail,
        });
        return;
      case '22P02': // invalid input syntax
        res.status(400).json({
          status: 'error',
          statusCode: 400,
          message: 'Format input tidak valid',
        });
        return;
    }
  }

  // JWT Errors
  if (err.name === 'JsonWebTokenError') {
    res.status(401).json({
      status: 'error',
      statusCode: 401,
      message: 'Token tidak valid',
    });
    return;
  }

  if (err.name === 'TokenExpiredError') {
    res.status(401).json({
      status: 'error',
      statusCode: 401,
      message: 'Token sudah expired',
    });
    return;
  }

  // Multer Errors
  if (err.name === 'MulterError') {
    res.status(400).json({
      status: 'error',
      statusCode: 400,
      message: 'Error upload file: ' + err.message,
    });
    return;
  }

  // Log unexpected errors
  logger.error('Unexpected error:', {
    message: err.message,
    stack: err.stack,
    url: req.url,
    method: req.method,
    body: req.body,
    user: (req as any).user?.id,
  });

  // Generic Error
  res.status(500).json({
    status: 'error',
    statusCode: 500,
    message: process.env.NODE_ENV === 'development'
      ? err.message
      : 'Internal server error',
  });
};