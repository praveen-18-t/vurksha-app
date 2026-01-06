/**
 * Address Validation Schemas
 */

import { z } from 'zod';

export const createAddressSchema = z.object({
  label: z.enum(['Home', 'Work', 'Other']).default('Home'),
  fullName: z.string().min(2).max(100),
  phoneNumber: z
    .string()
    .regex(/^\+91[6-9]\d{9}$/, 'Invalid phone number'),
  addressLine1: z.string().min(5).max(200),
  addressLine2: z.string().max(200).optional(),
  landmark: z.string().max(100).optional(),
  city: z.string().min(2).max(100),
  state: z.string().min(2).max(100),
  pincode: z.string().regex(/^\d{6}$/, 'Invalid pincode'),
  country: z.string().default('India'),
  latitude: z.number().min(-90).max(90).optional(),
  longitude: z.number().min(-180).max(180).optional(),
  isDefault: z.boolean().default(false),
});

export const updateAddressSchema = createAddressSchema.partial();

export const addressParamsSchema = z.object({
  id: z.string().uuid('Invalid address ID'),
});

// Type exports
export type CreateAddressInput = z.infer<typeof createAddressSchema>;
export type UpdateAddressInput = z.infer<typeof updateAddressSchema>;
export type AddressParams = z.infer<typeof addressParamsSchema>;
