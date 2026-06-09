import bcrypt from 'bcrypt';
import AppConfig from '@config/app.config';
import dayjs from 'dayjs';

// Hash Password
export const hashPassword = async (password: string): Promise<string> => {
  return bcrypt.hash(password, AppConfig.BCRYPT_ROUNDS);
};

// Compare Password
export const comparePassword = async (
  password: string,
  hash: string
): Promise<boolean> => {
  return bcrypt.compare(password, hash);
};

// Calculate Distance (Haversine Formula)
export const calculateDistance = (
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number => {
  const R = 6371000; // radius bumi dalam meter
  const phi1 = (lat1 * Math.PI) / 180;
  const phi2 = (lat2 * Math.PI) / 180;
  const dPhi = ((lat2 - lat1) * Math.PI) / 180;
  const dLambda = ((lon2 - lon1) * Math.PI) / 180;

  const a =
    Math.sin(dPhi / 2) * Math.sin(dPhi / 2) +
    Math.cos(phi1) *
      Math.cos(phi2) *
      Math.sin(dLambda / 2) *
      Math.sin(dLambda / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return Math.round(R * c);
};

// Check Within Radius
export const isWithinRadius = (
  distance: number,
  radius: number
): boolean => {
  return distance <= radius;
};

// Format Date
export const formatDate = (
  date: Date | string,
  format: string = 'YYYY-MM-DD'
): string => {
  return dayjs(date).format(format);
};

// Format DateTime
export const formatDateTime = (
  date: Date | string,
  format: string = 'YYYY-MM-DD HH:mm:ss'
): string => {
  return dayjs(date).format(format);
};

// Get Date Range
export const getDateRange = (
  startDate: string,
  endDate: string
): string[] => {
  const dates: string[] = [];
  let current = dayjs(startDate);
  const end = dayjs(endDate);

  while (current.isBefore(end) || current.isSame(end)) {
    dates.push(current.format('YYYY-MM-DD'));
    current = current.add(1, 'day');
  }

  return dates;
};

// Count Working Days
export const countWorkingDays = (
  startDate: string,
  endDate: string
): number => {
  const dates = getDateRange(startDate, endDate);
  return dates.filter((date) => {
    const day = dayjs(date).day();
    return day !== 0 && day !== 6; // exclude Sunday(0) and Saturday(6)
  }).length;
};

// Generate NIP
export const generateNIP = (
  clientCode: string,
  departmentCode: string,
  sequence: number
): string => {
  const year = dayjs().format('YY');
  const month = dayjs().format('MM');
  const seq = String(sequence).padStart(4, '0');
  return `${clientCode}-${departmentCode}-${year}${month}-${seq}`;
};

// Sanitize String
export const sanitizeString = (str: string): string => {
  return str.trim().replace(/[<>]/g, '');
};

// Parse Boolean
export const parseBoolean = (value: any): boolean => {
  if (typeof value === 'boolean') return value;
  if (typeof value === 'string') {
    return value.toLowerCase() === 'true' || value === '1';
  }
  return Boolean(value);
};
// Generate Random String
export const generateRandomString = (length: number = 32): string => {
  const chars =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let result = '';
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
};

// Mask Sensitive Data
export const maskEmail = (email: string): string => {
  const [local, domain] = email.split('@');
  const masked = local.substring(0, 2) + '*'.repeat(local.length - 2);
  return `${masked}@${domain}`;
};

export const maskPhone = (phone: string): string => {
  return phone.substring(0, 4) + '*'.repeat(phone.length - 7) +
    phone.substring(phone.length - 3);
};

// Validate Coordinate
export const isValidCoordinate = (
  lat: number,
  lon: number
): boolean => {
  return (
    lat >= -90 && lat <= 90 &&
    lon >= -180 && lon <= 180
  );
};

// Format File Size
export const formatFileSize = (bytes: number): string => {
  if (bytes === 0) return '0 Bytes';
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return `${parseFloat((bytes / Math.pow(k, i)).toFixed(2))} ${sizes[i]}`;
};

// Parse Sort Query
export const parseSortQuery = (
  sort?: string,
  allowedFields: string[] = []
): { column: string; order: 'asc' | 'desc' } => {
  if (!sort) return { column: 'created_at', order: 'desc' };

  const [column, order] = sort.split(':');
  const validOrder = order === 'asc' ? 'asc' : 'desc';
  const validColumn = allowedFields.includes(column)
    ? column
    : 'created_at';

  return { column: validColumn, order: validOrder };
};