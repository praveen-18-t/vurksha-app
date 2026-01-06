/**
 * Address Service
 * Handles delivery address operations
 */

import { prisma, withDbTimeout } from '../lib/prisma';
import { redis } from '../lib/redis';
import { logger } from '@vurksha/shared';
import { NotFoundError, BadRequestError } from '@vurksha/shared';
import { CreateAddressInput, UpdateAddressInput } from '../schemas/address.schema';

const log = logger.child({ service: 'address' });
const MAX_ADDRESSES = 10;

export interface AddressDto {
  id: string;
  label: string;
  fullName: string;
  phoneNumber: string;
  addressLine1: string;
  addressLine2: string | null;
  landmark: string | null;
  city: string;
  state: string;
  pincode: string;
  country: string;
  latitude: number | null;
  longitude: number | null;
  isDefault: boolean;
}

export class AddressService {
  /**
   * Get all addresses for a user
   */
  async getByUserId(userId: string): Promise<AddressDto[]> {
    const addresses = await withDbTimeout(() =>
      prisma.address.findMany({
        where: { userId, isActive: true },
        orderBy: [{ isDefault: 'desc' }, { createdAt: 'desc' }],
      })
    );

    return addresses.map(this.toDto);
  }

  /**
   * Get single address
   */
  async getById(addressId: string, userId: string): Promise<AddressDto> {
    const address = await withDbTimeout(() =>
      prisma.address.findFirst({
        where: { id: addressId, userId, isActive: true },
      })
    );

    if (!address) {
      throw new NotFoundError('Address', addressId);
    }

    return this.toDto(address);
  }

  /**
   * Create new address
   */
  async create(userId: string, input: CreateAddressInput): Promise<AddressDto> {
    // Check address limit
    const count = await prisma.address.count({
      where: { userId, isActive: true },
    });

    if (count >= MAX_ADDRESSES) {
      throw new BadRequestError(`Maximum ${MAX_ADDRESSES} addresses allowed`);
    }

    // If setting as default, unset other defaults
    if (input.isDefault) {
      await this.unsetDefaultAddresses(userId);
    }

    // If this is the first address, make it default
    const isFirstAddress = count === 0;

    const address = await withDbTimeout(() =>
      prisma.address.create({
        data: {
          userId,
          ...input,
          isDefault: input.isDefault || isFirstAddress,
        },
      })
    );

    log.info({ userId, addressId: address.id }, 'Address created');

    return this.toDto(address);
  }

  /**
   * Update address
   */
  async update(
    addressId: string,
    userId: string,
    input: UpdateAddressInput
  ): Promise<AddressDto> {
    const existing = await prisma.address.findFirst({
      where: { id: addressId, userId, isActive: true },
    });

    if (!existing) {
      throw new NotFoundError('Address', addressId);
    }

    // If setting as default, unset other defaults
    if (input.isDefault) {
      await this.unsetDefaultAddresses(userId);
    }

    const address = await withDbTimeout(() =>
      prisma.address.update({
        where: { id: addressId },
        data: input,
      })
    );

    log.info({ userId, addressId }, 'Address updated');

    return this.toDto(address);
  }

  /**
   * Delete address (soft delete)
   */
  async delete(addressId: string, userId: string): Promise<void> {
    const address = await prisma.address.findFirst({
      where: { id: addressId, userId, isActive: true },
    });

    if (!address) {
      throw new NotFoundError('Address', addressId);
    }

    await prisma.address.update({
      where: { id: addressId },
      data: { isActive: false },
    });

    // If deleted address was default, make another one default
    if (address.isDefault) {
      const nextAddress = await prisma.address.findFirst({
        where: { userId, isActive: true },
        orderBy: { createdAt: 'desc' },
      });

      if (nextAddress) {
        await prisma.address.update({
          where: { id: nextAddress.id },
          data: { isDefault: true },
        });
      }
    }

    log.info({ userId, addressId }, 'Address deleted');
  }

  /**
   * Set address as default
   */
  async setDefault(addressId: string, userId: string): Promise<AddressDto> {
    const address = await prisma.address.findFirst({
      where: { id: addressId, userId, isActive: true },
    });

    if (!address) {
      throw new NotFoundError('Address', addressId);
    }

    await this.unsetDefaultAddresses(userId);

    const updated = await prisma.address.update({
      where: { id: addressId },
      data: { isDefault: true },
    });

    log.info({ userId, addressId }, 'Default address updated');

    return this.toDto(updated);
  }

  private async unsetDefaultAddresses(userId: string): Promise<void> {
    await prisma.address.updateMany({
      where: { userId, isDefault: true },
      data: { isDefault: false },
    });
  }

  private toDto(address: {
    id: string;
    label: string;
    fullName: string;
    phoneNumber: string;
    addressLine1: string;
    addressLine2: string | null;
    landmark: string | null;
    city: string;
    state: string;
    pincode: string;
    country: string;
    latitude: number | null;
    longitude: number | null;
    isDefault: boolean;
  }): AddressDto {
    return {
      id: address.id,
      label: address.label,
      fullName: address.fullName,
      phoneNumber: address.phoneNumber,
      addressLine1: address.addressLine1,
      addressLine2: address.addressLine2,
      landmark: address.landmark,
      city: address.city,
      state: address.state,
      pincode: address.pincode,
      country: address.country,
      latitude: address.latitude,
      longitude: address.longitude,
      isDefault: address.isDefault,
    };
  }
}

export const addressService = new AddressService();
