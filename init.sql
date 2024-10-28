# Create the init.sql file
@'
-- Enable password authentication
CREATE USER platform_dev WITH PASSWORD 'dev_password';

-- Create database
CREATE DATABASE platform_dev;

-- Grant privileges
ALTER USER platform_dev WITH SUPERUSER;
GRANT ALL PRIVILEGES ON DATABASE platform_dev TO platform_dev;

-- Connect to platform_dev database
\c platform_dev

-- Grant schema privileges
GRANT ALL ON SCHEMA public TO platform_dev;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO platform_dev;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO platform_dev;
'@ | Out-File -FilePath "init-scripts/init.sql" -Encoding UTF8