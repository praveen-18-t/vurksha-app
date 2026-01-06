-- Initialize databases for each service
-- Run during PostgreSQL container initialization

-- Create databases for each microservice
CREATE DATABASE vurksha_users;
CREATE DATABASE vurksha_products;
CREATE DATABASE vurksha_orders;
CREATE DATABASE vurksha_notifications;

-- Grant all privileges to the main user
GRANT ALL PRIVILEGES ON DATABASE vurksha_users TO vurksha;
GRANT ALL PRIVILEGES ON DATABASE vurksha_products TO vurksha;
GRANT ALL PRIVILEGES ON DATABASE vurksha_orders TO vurksha;
GRANT ALL PRIVILEGES ON DATABASE vurksha_notifications TO vurksha;
