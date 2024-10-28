CREATE USER platform_dev WITH PASSWORD 'dev_password';
CREATE DATABASE platform_dev;
GRANT ALL PRIVILEGES ON DATABASE platform_dev TO platform_dev;
\c platform_dev
GRANT ALL ON SCHEMA public TO platform_dev;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO platform_dev;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO platform_dev;
