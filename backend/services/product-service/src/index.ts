/**
 * Product Service Entry Point
 */

import Fastify, { FastifyInstance } from 'fastify';
import cors from '@fastify/cors';
import helmet from '@fastify/helmet';
import jwt from '@fastify/jwt';
import {
  requestIdMiddleware,
  errorHandler,
  healthCheckPlugin,
  HealthChecks,
  logger,
} from '@vurksha/shared';
import { PrismaClient } from '@prisma/client';
import Redis from 'ioredis';

// Configuration
const config = {
  port: parseInt(process.env.PORT || '3002'),
  host: process.env.HOST || '0.0.0.0',
  jwtSecret: process.env.JWT_SECRET || 'development-secret',
  databaseUrl: process.env.DATABASE_URL!,
  redisUrl: process.env.REDIS_URL!,
};

// Database and cache clients
const prisma = new PrismaClient();
const redis = new Redis(config.redisUrl);

const log = logger.child({ service: 'product-service' });

async function createServer(): Promise<FastifyInstance> {
  const server = Fastify({
    logger: false,
    requestIdHeader: 'x-request-id',
    trustProxy: true,
  });

  await server.register(helmet, { contentSecurityPolicy: false });
  await server.register(cors, { origin: true, credentials: true });
  await server.register(jwt, { secret: config.jwtSecret });
  await server.register(requestIdMiddleware);
  await server.register(errorHandler);
  await server.register(healthCheckPlugin, {
    dependencies: [
      HealthChecks.postgres(prisma),
      HealthChecks.redis(redis),
    ],
  });

  // Product routes
  server.register(productRoutes, { prefix: '/api/v1/products' });
  server.register(categoryRoutes, { prefix: '/api/v1/categories' });
  server.register(bannerRoutes, { prefix: '/api/v1/banners' });

  return server;
}

// Product routes
import { FastifyPluginCallback } from 'fastify';
import { z } from 'zod';
import { successResponse, validate, PaginationSchema } from '@vurksha/shared';

const CACHE_TTL = 60; // 1 minute for product data

const productRoutes: FastifyPluginCallback = (fastify, _opts, done) => {
  /**
   * GET /products
   * List products with filtering and pagination
   */
  fastify.get('/', async (request, reply) => {
    const querySchema = PaginationSchema.extend({
      categoryId: z.string().uuid().optional(),
      search: z.string().optional(),
      isOrganic: z.coerce.boolean().optional(),
      minPrice: z.coerce.number().optional(),
      maxPrice: z.coerce.number().optional(),
      inStock: z.coerce.boolean().optional(),
    });

    const query = querySchema.parse(request.query);
    const { page, limit, categoryId, search, isOrganic, minPrice, maxPrice, inStock } = query;

    // Build cache key
    const cacheKey = `products:list:${JSON.stringify(query)}`;
    const cached = await redis.get(cacheKey);

    if (cached) {
      const response = successResponse(JSON.parse(cached), request.requestId);
      return reply.send(response);
    }

    // Build where clause
    const where: Record<string, unknown> = { isActive: true };
    if (categoryId) where.categoryId = categoryId;
    if (isOrganic !== undefined) where.isOrganic = isOrganic;
    if (inStock) where.stock = { gt: 0 };
    if (minPrice || maxPrice) {
      where.price = {};
      if (minPrice) (where.price as Record<string, unknown>).gte = minPrice;
      if (maxPrice) (where.price as Record<string, unknown>).lte = maxPrice;
    }
    if (search) {
      where.OR = [
        { name: { contains: search, mode: 'insensitive' } },
        { description: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [products, total] = await Promise.all([
      prisma.product.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          category: { select: { id: true, name: true, slug: true } },
          images: { where: { isPrimary: true }, take: 1 },
          tags: { select: { name: true } },
        },
      }),
      prisma.product.count({ where }),
    ]);

    const result = {
      products: products.map((p) => ({
        id: p.id,
        name: p.name,
        slug: p.slug,
        description: p.shortDescription || p.description.substring(0, 150),
        price: Number(p.price),
        compareAtPrice: p.compareAtPrice ? Number(p.compareAtPrice) : null,
        unit: p.unit,
        stock: p.stock,
        isOrganic: p.isOrganic,
        farmSource: p.farmSource,
        averageRating: Number(p.averageRating),
        reviewCount: p.reviewCount,
        imageUrl: p.images[0]?.url || null,
        category: p.category,
        tags: p.tags.map((t) => t.name),
        inStock: p.stock > 0,
      })),
    };

    // Cache result
    await redis.setex(cacheKey, CACHE_TTL, JSON.stringify(result));

    const response = successResponse(result, request.requestId, {
      page,
      limit,
      total,
    });
    return reply.send(response);
  });

  /**
   * GET /products/:id
   * Get product by ID
   */
  fastify.get('/:id', async (request, reply) => {
    const { id } = z.object({ id: z.string().uuid() }).parse(request.params);

    const cacheKey = `product:${id}`;
    const cached = await redis.get(cacheKey);

    if (cached) {
      const response = successResponse(JSON.parse(cached), request.requestId);
      return reply.send(response);
    }

    const product = await prisma.product.findUnique({
      where: { id, isActive: true },
      include: {
        category: true,
        images: { orderBy: { sortOrder: 'asc' } },
        tags: true,
        reviews: {
          where: { isApproved: true },
          orderBy: { createdAt: 'desc' },
          take: 10,
        },
      },
    });

    if (!product) {
      return reply.status(404).send({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Product not found', retryable: false },
        meta: { requestId: request.requestId, timestamp: new Date().toISOString(), version: '1.0.0' },
      });
    }

    const result = {
      product: {
        id: product.id,
        name: product.name,
        slug: product.slug,
        description: product.description,
        shortDescription: product.shortDescription,
        price: Number(product.price),
        compareAtPrice: product.compareAtPrice ? Number(product.compareAtPrice) : null,
        unit: product.unit,
        minOrderQuantity: product.minOrderQuantity,
        maxOrderQuantity: product.maxOrderQuantity,
        quantityStep: Number(product.quantityStep),
        stock: product.stock,
        isOrganic: product.isOrganic,
        farmSource: product.farmSource,
        shelfLife: product.shelfLife,
        storageInstructions: product.storageInstructions,
        nutritionInfo: product.nutritionInfo,
        averageRating: Number(product.averageRating),
        reviewCount: product.reviewCount,
        isFeatured: product.isFeatured,
        category: product.category,
        images: product.images,
        tags: product.tags.map((t) => t.name),
        reviews: product.reviews.map((r) => ({
          id: r.id,
          rating: r.rating,
          title: r.title,
          comment: r.comment,
          isVerified: r.isVerified,
          createdAt: r.createdAt.toISOString(),
        })),
        inStock: product.stock > 0,
      },
    };

    await redis.setex(cacheKey, CACHE_TTL, JSON.stringify(result));

    const response = successResponse(result, request.requestId);
    return reply.send(response);
  });

  /**
   * GET /products/featured
   * Get featured products
   */
  fastify.get('/featured', async (request, reply) => {
    const cacheKey = 'products:featured';
    const cached = await redis.get(cacheKey);

    if (cached) {
      const response = successResponse(JSON.parse(cached), request.requestId);
      return reply.send(response);
    }

    const products = await prisma.product.findMany({
      where: { isActive: true, isFeatured: true, stock: { gt: 0 } },
      take: 10,
      orderBy: { salesCount: 'desc' },
      include: {
        images: { where: { isPrimary: true }, take: 1 },
        category: { select: { name: true } },
      },
    });

    const result = {
      products: products.map((p) => ({
        id: p.id,
        name: p.name,
        slug: p.slug,
        price: Number(p.price),
        compareAtPrice: p.compareAtPrice ? Number(p.compareAtPrice) : null,
        unit: p.unit,
        imageUrl: p.images[0]?.url || null,
        category: p.category.name,
        isOrganic: p.isOrganic,
        averageRating: Number(p.averageRating),
      })),
    };

    await redis.setex(cacheKey, CACHE_TTL * 5, JSON.stringify(result));

    const response = successResponse(result, request.requestId);
    return reply.send(response);
  });

  done();
};

// Category routes
const categoryRoutes: FastifyPluginCallback = (fastify, _opts, done) => {
  /**
   * GET /categories
   * Get all categories
   */
  fastify.get('/', async (request, reply) => {
    const cacheKey = 'categories:all';
    const cached = await redis.get(cacheKey);

    if (cached) {
      const response = successResponse(JSON.parse(cached), request.requestId);
      return reply.send(response);
    }

    const categories = await prisma.category.findMany({
      where: { isActive: true, parentId: null },
      orderBy: { sortOrder: 'asc' },
      include: {
        children: {
          where: { isActive: true },
          orderBy: { sortOrder: 'asc' },
        },
        _count: { select: { products: true } },
      },
    });

    const result = {
      categories: categories.map((c) => ({
        id: c.id,
        name: c.name,
        slug: c.slug,
        description: c.description,
        imageUrl: c.imageUrl,
        productCount: c._count.products,
        children: c.children.map((child) => ({
          id: child.id,
          name: child.name,
          slug: child.slug,
          imageUrl: child.imageUrl,
        })),
      })),
    };

    await redis.setex(cacheKey, CACHE_TTL * 10, JSON.stringify(result));

    const response = successResponse(result, request.requestId);
    return reply.send(response);
  });

  /**
   * GET /categories/:slug
   * Get category by slug
   */
  fastify.get('/:slug', async (request, reply) => {
    const { slug } = z.object({ slug: z.string() }).parse(request.params);

    const category = await prisma.category.findUnique({
      where: { slug, isActive: true },
      include: {
        children: { where: { isActive: true } },
        parent: true,
      },
    });

    if (!category) {
      return reply.status(404).send({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Category not found', retryable: false },
        meta: { requestId: request.requestId, timestamp: new Date().toISOString(), version: '1.0.0' },
      });
    }

    const response = successResponse({ category }, request.requestId);
    return reply.send(response);
  });

  done();
};

// Banner routes
const bannerRoutes: FastifyPluginCallback = (fastify, _opts, done) => {
  /**
   * GET /banners
   * Get active banners
   */
  fastify.get('/', async (request, reply) => {
    const { position } = z.object({ position: z.string().default('home') }).parse(request.query);

    const cacheKey = `banners:${position}`;
    const cached = await redis.get(cacheKey);

    if (cached) {
      const response = successResponse(JSON.parse(cached), request.requestId);
      return reply.send(response);
    }

    const now = new Date();
    const banners = await prisma.banner.findMany({
      where: {
        isActive: true,
        position,
        OR: [
          { startDate: null, endDate: null },
          { startDate: { lte: now }, endDate: { gte: now } },
          { startDate: { lte: now }, endDate: null },
          { startDate: null, endDate: { gte: now } },
        ],
      },
      orderBy: { sortOrder: 'asc' },
    });

    const result = {
      banners: banners.map((b) => ({
        id: b.id,
        title: b.title,
        subtitle: b.subtitle,
        imageUrl: b.imageUrl,
        linkType: b.linkType,
        linkValue: b.linkValue,
      })),
    };

    await redis.setex(cacheKey, CACHE_TTL * 5, JSON.stringify(result));

    const response = successResponse(result, request.requestId);
    return reply.send(response);
  });

  done();
};

// Start server
async function main() {
  const server = await createServer();

  const signals: NodeJS.Signals[] = ['SIGINT', 'SIGTERM'];
  for (const signal of signals) {
    process.on(signal, async () => {
      log.info({ signal }, 'Shutdown signal received');
      await server.close();
      await prisma.$disconnect();
      await redis.quit();
      process.exit(0);
    });
  }

  try {
    await server.listen({ port: config.port, host: config.host });
    log.info({ port: config.port }, 'Product service started');
  } catch (error) {
    log.fatal({ error }, 'Failed to start server');
    process.exit(1);
  }
}

main();
