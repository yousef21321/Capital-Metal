-- Create a new database user for flfl_design
-- Replace 'flfl_user' and 'YourSecurePassword123!' with your desired username and password

CREATE USER IF NOT EXISTS 'flfl_user'@'%' IDENTIFIED BY 'YourSecurePassword123!';

-- Grant privileges on the flfl_design database only
GRANT ALL PRIVILEGES ON flfl_design.* TO 'flfl_user'@'%';

FLUSH PRIVILEGES;

-- Show the created user
SELECT user, host FROM mysql.user WHERE user = 'flfl_user';
