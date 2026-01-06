/**
 * Authentication Validation Schemas
 */

import { z } from 'zod';

export const sendOtpSchema = z.object({
  phoneNumber: z
    .string()
    .regex(/^\+91[6-9]\d{9}$/, 'Invalid phone number. Must be in format +91XXXXXXXXXX'),
});

export const verifyOtpSchema = z.object({
  phoneNumber: z
    .string()
    .regex(/^\+91[6-9]\d{9}$/, 'Invalid phone number'),
  otp: z
    .string()
    .length(6, 'OTP must be 6 digits')
    .regex(/^\d+$/, 'OTP must contain only digits'),
  deviceId: z.string().optional(),
  deviceName: z.string().optional(),
  deviceType: z.enum(['ios', 'android', 'web']).optional(),
});

export const refreshTokenSchema = z.object({
  refreshToken: z.string().min(1, 'Refresh token is required'),
});

export const logoutSchema = z.object({
  refreshToken: z.string().optional(),
  allDevices: z.boolean().default(false),
});

// Type exports
export type SendOtpInput = z.infer<typeof sendOtpSchema>;
export type VerifyOtpInput = z.infer<typeof verifyOtpSchema>;
export type RefreshTokenInput = z.infer<typeof refreshTokenSchema>;
export type LogoutInput = z.infer<typeof logoutSchema>;
