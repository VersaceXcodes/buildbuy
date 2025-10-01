#!/bin/bash

echo "🚀 Testing Full System Integration"
echo "=================================="

# Test 1: Health endpoint
echo "1. Testing health endpoint..."
HEALTH_RESPONSE=$(curl -s http://localhost:3000/api/health)
if [[ $HEALTH_RESPONSE == *"healthy"* ]]; then
    echo "✅ Health endpoint working"
else
    echo "❌ Health endpoint failed"
    echo "Response: $HEALTH_RESPONSE"
fi

# Test 2: User registration
echo ""
echo "2. Testing user registration..."
REG_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
    -d '{"email":"testuser@example.com","password":"password123","name":"Test User"}' \
    http://localhost:3000/api/auth/register)

if [[ $REG_RESPONSE == *"token"* ]]; then
    echo "✅ User registration working"
    TOKEN=$(echo $REG_RESPONSE | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')
    echo "Token extracted: ${TOKEN:0:20}..."
else
    echo "❌ User registration failed"
    echo "Response: $REG_RESPONSE"
fi

# Test 3: User login
echo ""
echo "3. Testing user login..."
LOGIN_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
    -d '{"email":"testuser@example.com","password":"password123"}' \
    http://localhost:3000/api/auth/login)

if [[ $LOGIN_RESPONSE == *"token"* ]]; then
    echo "✅ User login working"
    LOGIN_TOKEN=$(echo $LOGIN_RESPONSE | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')
else
    echo "❌ User login failed"
    echo "Response: $LOGIN_RESPONSE"
fi

# Test 4: Token verification
echo ""
echo "4. Testing token verification..."
VERIFY_RESPONSE=$(curl -s -H "Authorization: Bearer $LOGIN_TOKEN" \
    http://localhost:3000/api/auth/verify)

if [[ $VERIFY_RESPONSE == *"Token is valid"* ]]; then
    echo "✅ Token verification working"
else
    echo "❌ Token verification failed"
    echo "Response: $VERIFY_RESPONSE"
fi

# Test 5: Frontend serving
echo ""
echo "5. Testing frontend serving..."
FRONTEND_RESPONSE=$(curl -s http://localhost:3000/ | head -5)
if [[ $FRONTEND_RESPONSE == *"<!doctype html>"* ]]; then
    echo "✅ Frontend serving from backend"
else
    echo "❌ Frontend serving failed"
fi

# Test 6: API contract validation
echo ""
echo "6. Testing API response structure..."
USER_DATA=$(echo $LOGIN_RESPONSE | grep -o '"user":{[^}]*}')
if [[ $USER_DATA == *"id"* ]] && [[ $USER_DATA == *"email"* ]] && [[ $USER_DATA == *"name"* ]]; then
    echo "✅ API response structure matches frontend expectations"
else
    echo "❌ API response structure mismatch"
    echo "User data: $USER_DATA"
fi

# Test 7: Query parameter coercion
echo ""
echo "7. Testing query parameter coercion..."
COERCION_TEST=$(curl -s "http://localhost:3000/api/health?limit=abc&offset=-5&active=true")
if [[ $COERCION_TEST == *"healthy"* ]]; then
    echo "✅ Query parameter coercion working (no 400 errors)"
else
    echo "❌ Query parameter coercion failed"
fi

echo ""
echo "🎉 System integration test complete!"
echo "====================================="