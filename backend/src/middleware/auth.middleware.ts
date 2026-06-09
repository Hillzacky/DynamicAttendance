import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { db } from '@config/database';
import { AppError } from '@utils/AppError';
import AppConfig from '@config/app.config';

// Extend Request interface
declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string;
        username: string;
        fullname: string;
        email: string;
        role: string;
        client_id: string;
        department_id: string;
        position_id: string;
        status: string;
      };
    }
  }
}

// JWT Payload Interface
interface JwtPayload {
  id: string;
  username: string;
  role: string;
  client_id: string;
  iat: number;
  exp: number;
}

// =============================================
// Verify Token Middleware
// =============================================
export const authenticate = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new AppError('Token tidak ditemukan', 401);
    }

    const token = authHeader.split(' ');

    // Verify token
    const decoded = jwt.verify(
      token,
      AppConfig.JWT_SECRET
    ) as JwtPayload;

    // Get user from database
    const user = await db('users')
      .where({ id: decoded.id, status: 'active' })
      .first();

    if (!user) {
      throw new AppError('User tidak ditemukan atau tidak aktif', 401);
    }

    // Attach user to request
    req.user = {
      id: user.id,
      username: user.username,
      fullname: user.fullname,
      email: user.email,
      role: user.role,
      client_id: user.client_id,
      department_id: user.department_id,
      position_id: user.position_id,
      status: user.status,
    };

    next();
  } catch (error) {
    next(error);
  }
};

// =============================================
// Role Authorization Middleware
// =============================================
export const authorize = (...roles: string[]) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    if (!req.user) {
      return next(new AppError('Unauthorized', 401));
    }

    if (!roles.includes(req.user.role)) {
      return next(new AppError(
        'Anda tidak memiliki akses untuk melakukan aksi ini', 403
      ));
    }

    next();
  };
};

// =============================================
// Check Same Client Middleware
// =============================================
export const sameClient = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { client_id } = req.params;

    if (req.user?.role === 'superadmin') {
      return next();
    }

    if (client_id && client_id !== req.user?.client_id) {
      throw new AppError('Akses ditolak: client tidak sesuai', 403);
    }

    next();
  } catch (error) {
    next(error);
  }
};