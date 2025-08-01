#!/bin/bash

# Test script to verify Adminer can connect to PostgreSQL
# This script simulates a login attempt to verify connectivity

echo "Testing Adminer database connection..."
echo "=================================="

# Test if Adminer login page is accessible
echo "1. Testing Adminer accessibility..."
ADMINER_RESPONSE=$(curl -s -w "%{http_code}" http://localhost:8081 -o /dev/null)
if [ "$ADMINER_RESPONSE" = "200" ]; then
    echo "✅ Adminer is accessible at http://localhost:8081"
else
    echo "❌ Adminer is not accessible (HTTP $ADMINER_RESPONSE)"
    exit 1
fi

# Test database connectivity from within the network
echo "2. Testing database connectivity from Adminer container..."
DB_TEST=$(docker compose exec -T adminer sh -c "php -r \"
try {
    \$pdo = new PDO('pgsql:host=postgres;port=5432;dbname=likha_licensing', 'postgres', 'postgres');
    echo 'Database connection successful';
    \$result = \$pdo->query('SELECT current_database(), current_user;');
    \$row = \$result->fetch(PDO::FETCH_ASSOC);
    echo ' - Database: ' . \$row['current_database'];
    echo ' - User: ' . \$row['current_user'];
} catch (Exception \$e) {
    echo 'Database connection failed: ' . \$e->getMessage();
    exit(1);
}
\"")

if echo "$DB_TEST" | grep -q "Database connection successful"; then
    echo "✅ Adminer can connect to PostgreSQL database"
    echo "   $DB_TEST"
else
    echo "❌ Adminer cannot connect to PostgreSQL database"
    echo "   $DB_TEST"
    exit 1
fi

echo ""
echo "🎉 All tests passed! Adminer is properly configured and can connect to PostgreSQL."
echo ""
echo "📍 Access Adminer at: http://localhost:8081"
echo "   Server: postgres"
echo "   Username: postgres"
echo "   Password: postgres"
echo "   Database: likha_licensing"