import jwt from 'jsonwebtoken';
import AppConfig from '@config/app.config';

interface TokenPayload {
  id: string;
  username: string;
  role: string;
  client_id: string;
}

interface RefreshTokenPayload {
  id: string;
  type: string;
}

export const generateAccessToken = (payload: TokenPayload): string => {
  return jwt.sign(payload, AppConfig.JWT_SECRET, {
    expiresIn: AppConfig.JWT_EXPIRES_IN,
  } as jwt.SignOptions);
};

export const generateRefreshToken = (userId: string): string => {
  return jwt.sign(
    { id: userId, type: 'refresh' },
    AppConfig.JWT_REFRESH_SECRET,
    { expiresIn: AppConfig.JWT_REFRESH_EXPIRES_IN } as jwt.SignOptions
  );
};

export const verifyAccessToken = (token: string): TokenPayload => {
  return jwt.verify(token, AppConfig.JWT_SECRET) as TokenPayload;
};

export const verifyRefreshToken = (token: string): RefreshTokenPayload => {
  return jwt.verify(
    token, AppConfig.JWT_REFRESH_SECRET
  ) as RefreshTokenPayload;
};

export const decodeToken = (token: string): any => {
  return jwt.decode(token);
};