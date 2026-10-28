-- Create a new database user for capital_metal
-- Replace 'capitalmetal_user' and 'YourSecurePassword123!' with your desired username and password

CREATE USER IF NOT EXISTS 'capitalmetal_user'@'%' IDENTIFIED BY 'YourSecurePassword123!';

-- Grant privileges on the capital_metal database only
GRANT ALL PRIVILEGES ON capital_metal.* TO 'capitalmetal_user'@'%';

FLUSH PRIVILEGES;

-- Show the created user
SELECT user, host FROM mysql.user WHERE user = 'capitalmetal_user';
