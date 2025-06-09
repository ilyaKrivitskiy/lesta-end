#!/bin/sh

echo "Check migrations..."

if [ ! -d "migrations" ]; then
    echo "Migrations folder did not found. Creating..."
    flask db init
fi

echo "Make migrations..."
flask db migrate -m "auto migration" || true

echo "Apply migrations..."
flask db upgrade

echo "Start the application..."
exec python routes.py