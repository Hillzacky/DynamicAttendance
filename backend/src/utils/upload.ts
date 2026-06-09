import multer, { FileFilterCallback } from 'multer';
import path from 'path';
import fs from 'fs';
import { Request } from 'express';
import AppConfig from '@config/app.config';
import { v4 as uuidv4 } from 'uuid';

// Ensure upload directories exist
const ensureDir = (dir: string): void => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
};

const uploadDirs = {
  avatar: path.join(AppConfig.UPLOAD_DIR, 'avatars'),
  attendance: path.join(AppConfig.UPLOAD_DIR, 'attendance'),
  leave: path.join(AppConfig.UPLOAD_DIR, 'leaves'),
  temp: path.join(AppConfig.UPLOAD_DIR, 'temp'),
};

Object.values(uploadDirs).forEach(ensureDir);

// Storage Configuration
const diskStorage = (folder: string) =>
  multer.diskStorage({
    destination: (req, file, cb) => {
      const uploadPath = path.join(AppConfig.UPLOAD_DIR, folder);
      ensureDir(uploadPath);
      cb(null, uploadPath);
    },
    filename: (req, file, cb) => {
      const uniqueName = `${uuidv4()}-${Date.now()}${path.extname(
        file.originalname
      )}`;
      cb(null, uniqueName);
    },
  });

// File Filter
const imageFilter = (
  req: Request,
  file: Express.Multer.File,
  cb: FileFilterCallback
): void => {
  if (AppConfig.ALLOWED_IMAGE_TYPES.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Hanya file gambar (JPEG, PNG, WebP) yang diizinkan'));
  }
};

const documentFilter = (
  req: Request,
  file: Express.Multer.File,
  cb: FileFilterCallback
): void => {
  if (AppConfig.ALLOWED_DOC_TYPES.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Hanya file gambar atau PDF yang diizinkan'));
  }
};

// Upload Instances
export const uploadAvatar = multer({
  storage: diskStorage('avatars'),
  fileFilter: imageFilter,
  limits: { fileSize: AppConfig.MAX_FILE_SIZE },
}).single('avatar');

export const uploadAttendancePhoto = multer({
  storage: diskStorage('attendance'),
  fileFilter: imageFilter,
  limits: { fileSize: AppConfig.MAX_FILE_SIZE },
}).single('photo');

export const uploadLeaveDocument = multer({
  storage: diskStorage('leaves'),
  fileFilter: documentFilter,
  limits: { fileSize: AppConfig.MAX_FILE_SIZE },
}).single('document');

// Get File URL
export const getFileUrl = (
  req: Request,
  filePath: string
): string => {
  return `${AppConfig.BASE_URL}/${filePath.replace(/\\/g, '/')}`;
};

// Delete File
export const deleteFile = (filePath: string): void => {
  const fullPath = path.join(__dirname, '../../', filePath);
  if (fs.existsSync(fullPath)) {
    fs.unlinkSync(fullPath);
  }
};