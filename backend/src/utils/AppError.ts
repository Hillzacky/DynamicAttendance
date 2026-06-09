export class AppError extends Error {
  statusCode: number;
  isOperational: boolean;

  constructor(message: string, statusCode: number = 500) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
    Object.setPrototypeOf(this, AppError.prototype);
  }
}

export class ValidationError extends AppError {
  errors: Record<string, string[]>;

  constructor(errors: Record<string, string[]>) {
    super('Validasi gagal', 422);
    this.errors = errors;
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string = 'Data') {
    super(`${resource} tidak ditemukan`, 404);
  }
}

export class UnauthorizedError extends AppError {
  constructor(message: string = 'Unauthorized') {
    super(message, 401);
  }
}

export class ForbiddenError extends AppError {
  constructor(message: string = 'Akses ditolak') {
    super(message, 403);
  }
}

export class ConflictError extends AppError {
  constructor(message: string = 'Data sudah ada') {
    super(message, 409);
  }
}