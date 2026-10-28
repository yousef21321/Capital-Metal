#!/bin/bash
# Setup database user for capital_metal
# Usage: ./setup-db-user.sh [username] [password]

USERNAME="${1:-capitalmetal_user}"
PASSWORD="${2:-YourSecurePassword123!}"

echo "Setting up database user: $USERNAME"

# Run SQL to create user
docker exec -i capitalmetal_db mysql -u root -proot <<EOF
CREATE USER IF NOT EXISTS '$USERNAME'@'%' IDENTIFIED BY '$PASSWORD';
GRANT ALL PRIVILEGES ON capital_metal.* TO '$USERNAME'@'%';
FLUSH PRIVILEGES;
SELECT user, host FROM mysql.user WHERE user = '$USERNAME';
EOF

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Database user created successfully!"
    echo ""
    echo "Update your .env or docker-compose.yml with:"
    echo "  DB_USERNAME=$USERNAME"
    echo "  DB_PASSWORD=$PASSWORD"
else
    echo "❌ Failed to create database user"
fi
