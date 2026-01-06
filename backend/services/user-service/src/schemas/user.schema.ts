/**
 * User Validation Schemas
 */

import { z } from 'zod';

export const updateUserSchema = z.object({
  name: z.string().min(2).max(100).optional(),
  email: z.string().email().optional(),
  profileImageUrl: z.string().url().optional(),
});

export const userParamsSchema = z.object({
  id: z.string().uuid('Invalid user ID'),
});

// Type exports
export type UpdateUserInput = z.infer<typeof updateUserSchema>;
export type UserParams = z.infer<typeof userParamsSchema>;
