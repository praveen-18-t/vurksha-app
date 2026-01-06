/**
 * Domain Events for async communication
 * Published to RabbitMQ for service-to-service communication
 */

export interface DomainEvent<T = unknown> {
  eventId: string;
  eventType: string;
  aggregateId: string;
  aggregateType: string;
  timestamp: string;
  version: number;
  payload: T;
  metadata: EventMetadata;
}

export interface EventMetadata {
  correlationId: string;
  causationId?: string;
  userId?: string;
  source: string;
}

// User Events
export interface UserCreatedEvent {
  userId: string;
  phoneNumber: string;
  createdAt: string;
}

export interface UserUpdatedEvent {
  userId: string;
  changes: Record<string, unknown>;
  updatedAt: string;
}

// Order Events
export interface OrderCreatedEvent {
  orderId: string;
  userId: string;
  items: Array<{
    productId: string;
    quantity: number;
    price: number;
  }>;
  totalAmount: number;
  deliveryAddress: string;
}

export interface OrderConfirmedEvent {
  orderId: string;
  confirmedAt: string;
  estimatedDelivery: string;
}

export interface OrderShippedEvent {
  orderId: string;
  shippedAt: string;
  trackingId: string;
  deliveryPartnerId: string;
}

export interface OrderDeliveredEvent {
  orderId: string;
  deliveredAt: string;
  deliveredTo: string;
}

export interface OrderCancelledEvent {
  orderId: string;
  cancelledAt: string;
  reason: string;
  refundInitiated: boolean;
}

// Payment Events
export interface PaymentInitiatedEvent {
  paymentId: string;
  orderId: string;
  amount: number;
  method: string;
}

export interface PaymentCompletedEvent {
  paymentId: string;
  orderId: string;
  transactionId: string;
  completedAt: string;
}

export interface PaymentFailedEvent {
  paymentId: string;
  orderId: string;
  reason: string;
  failedAt: string;
}

// Inventory Events
export interface StockUpdatedEvent {
  productId: string;
  previousStock: number;
  newStock: number;
  reason: string;
}

export interface LowStockAlertEvent {
  productId: string;
  currentStock: number;
  threshold: number;
}

// Notification Events
export interface NotificationRequestedEvent {
  userId: string;
  type: 'push' | 'sms' | 'email';
  template: string;
  data: Record<string, unknown>;
}

/**
 * Event type constants for routing
 */
export const EventTypes = {
  // User
  USER_CREATED: 'user.created',
  USER_UPDATED: 'user.updated',
  USER_DELETED: 'user.deleted',

  // Order
  ORDER_CREATED: 'order.created',
  ORDER_CONFIRMED: 'order.confirmed',
  ORDER_SHIPPED: 'order.shipped',
  ORDER_DELIVERED: 'order.delivered',
  ORDER_CANCELLED: 'order.cancelled',

  // Payment
  PAYMENT_INITIATED: 'payment.initiated',
  PAYMENT_COMPLETED: 'payment.completed',
  PAYMENT_FAILED: 'payment.failed',
  PAYMENT_REFUNDED: 'payment.refunded',

  // Inventory
  STOCK_UPDATED: 'inventory.stock_updated',
  LOW_STOCK_ALERT: 'inventory.low_stock',

  // Notification
  NOTIFICATION_REQUESTED: 'notification.requested',
  NOTIFICATION_SENT: 'notification.sent',
  NOTIFICATION_FAILED: 'notification.failed',
} as const;

export type EventType = (typeof EventTypes)[keyof typeof EventTypes];

/**
 * Exchange and queue names
 */
export const Exchanges = {
  DOMAIN_EVENTS: 'vurksha.events',
  DEAD_LETTER: 'vurksha.dlx',
} as const;

export const Queues = {
  ORDER_NOTIFICATIONS: 'order.notifications',
  INVENTORY_UPDATES: 'order.inventory',
  PAYMENT_PROCESSING: 'payment.processing',
  EMAIL_NOTIFICATIONS: 'notification.email',
  PUSH_NOTIFICATIONS: 'notification.push',
  SMS_NOTIFICATIONS: 'notification.sms',
} as const;
