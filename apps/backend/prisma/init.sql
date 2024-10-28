-- apps/backend/prisma/init.sql
CREATE USER platform_dev WITH PASSWORD 'dev_password';
CREATE DATABASE platform_dev;
GRANT ALL PRIVILEGES ON DATABASE platform_dev TO platform_dev;
ALTER USER platform_dev WITH SUPERUSER;