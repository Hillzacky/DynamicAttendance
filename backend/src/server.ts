import express, { Application, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import path from 'path';
import rateLimit from 'express-rate-limit';
import { testConnection } from '@config/database';
import AppConfig from '@config/app.config';
import { errorHandler } from '@middleware/error.middleware';
import { notFoundHandler } from '@middleware/notFound.middleware';
import routes from '@routes/index';

const app: Application = express();

// =============================================
// Security Middleware
// =============================================
app.use(helmet({
  crossOriginResourcePolicy: { policy: 'cross-origin' },
}));

app.use(cors({
  origin: AppConfig.CORS_ORIGIN,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  credentials: true,
  maxAge: 86400,
}));

// Rate Limiting
const limiter = rateLimit({
  windowMs: AppConfig.RATE_LIMIT_WINDOW,
  max: AppConfig.RATE_LIMIT_MAX,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    status: 429,
    message: 'Terlalu banyak request, coba lagi nanti',
  },
});
app.use(limiter);

// Auth rate limit (lebih ketat)
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 menit
  max: 10,
  message: {
    status: 429,
    message: 'Terlalu banyak percobaan login, coba lagi dalam 15 menit',
  },
});

// =============================================
// General Middleware
// =============================================
app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logging
if (AppConfig.NODE_ENV === 'development') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

// Static Files
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// =============================================
// Routes
// =============================================
app.use(`${AppConfig.API_PREFIX}/auth`, authLimiter);
app.use(AppConfig.API_PREFIX, routes);

// Health Check
app.get('/health', (req: Request, res: Response) => {
  res.status(200).json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    environment: AppConfig.NODE_ENV,
    version: process.env.npm_package_version || '1.0.0',
  });
});

// =============================================
// Error Handling
// =============================================
app.use(notFoundHandler);
app.use(errorHandler);

// =============================================
// Start Server
// =============================================
const startServer = async (): Promise<void> => {
  try {
    await testConnection();
    app.listen(AppConfig.PORT, () => {
      console.log(`
╔══════════════════════════════════════════╗
║     🚀 Attendance App API Server         ║
║══════════════════════════════════════════║
║  Environment : ${AppConfig.NODE_ENV.padEnd(25)}║
║  Port        : ${String(AppConfig.PORT).padEnd(25)}║
║  API Prefix  : ${AppConfig.API_PREFIX.padEnd(25)}║
╚══════════════════════════════════════════╝
      `);
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
};

startServer();

// Graceful Shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received, shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('SIGINT received, shutting down gracefully');
  process.exit(0);
});

export default app;