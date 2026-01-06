/**
 * Address Routes
 * Endpoints for delivery address management
 */

import { FastifyInstance, FastifyPluginCallback, FastifyRequest, FastifyReply } from 'fastify';
import { validate, successResponse } from '@vurksha/shared';
import { addressService } from '../services/address.service';
import {
  createAddressSchema,
  updateAddressSchema,
  addressParamsSchema,
  CreateAddressInput,
  UpdateAddressInput,
  AddressParams,
} from '../schemas/address.schema';

// Authentication decorator
const authenticate = async (request: FastifyRequest, _reply: FastifyReply) => {
  await request.jwtVerify();
};

export const addressRoutes: FastifyPluginCallback = (
  fastify: FastifyInstance,
  _opts,
  done
) => {
  // All routes require authentication
  fastify.addHook('preHandler', authenticate);

  /**
   * GET /addresses
   * Get all addresses for current user
   */
  fastify.get('/', async (request, reply) => {
    const userId = (request.user as { sub: string }).sub;
    const addresses = await addressService.getByUserId(userId);

    const response = successResponse({ addresses }, request.requestId);
    return reply.status(200).send(response);
  });

  /**
   * GET /addresses/:id
   * Get single address
   */
  fastify.get(
    '/:id',
    validate<unknown, AddressParams, unknown>(
      { params: addressParamsSchema },
      async (request, reply) => {
        const userId = (request.user as { sub: string }).sub;
        const address = await addressService.getById(
          request.params.id,
          userId
        );

        const response = successResponse({ address }, request.requestId);
        return reply.status(200).send(response);
      }
    )
  );

  /**
   * POST /addresses
   * Create new address
   */
  fastify.post(
    '/',
    validate<CreateAddressInput, unknown, unknown>(
      { body: createAddressSchema },
      async (request, reply) => {
        const userId = (request.user as { sub: string }).sub;

        const address = await addressService.create(userId, request.body);

        const response = successResponse({ address }, request.requestId);
        return reply.status(201).send(response);
      }
    )
  );

  /**
   * PUT /addresses/:id
   * Update address
   */
  fastify.put(
    '/:id',
    validate<UpdateAddressInput, AddressParams, unknown>(
      { body: updateAddressSchema, params: addressParamsSchema },
      async (request, reply) => {
        const userId = (request.user as { sub: string }).sub;

        const address = await addressService.update(
          request.params.id,
          userId,
          request.body
        );

        const response = successResponse({ address }, request.requestId);
        return reply.status(200).send(response);
      }
    )
  );

  /**
   * DELETE /addresses/:id
   * Delete address
   */
  fastify.delete(
    '/:id',
    validate<unknown, AddressParams, unknown>(
      { params: addressParamsSchema },
      async (request, reply) => {
        const userId = (request.user as { sub: string }).sub;

        await addressService.delete(request.params.id, userId);

        const response = successResponse(
          { message: 'Address deleted successfully' },
          request.requestId
        );
        return reply.status(200).send(response);
      }
    )
  );

  /**
   * POST /addresses/:id/default
   * Set address as default
   */
  fastify.post(
    '/:id/default',
    validate<unknown, AddressParams, unknown>(
      { params: addressParamsSchema },
      async (request, reply) => {
        const userId = (request.user as { sub: string }).sub;

        const address = await addressService.setDefault(
          request.params.id,
          userId
        );

        const response = successResponse({ address }, request.requestId);
        return reply.status(200).send(response);
      }
    )
  );

  done();
};
