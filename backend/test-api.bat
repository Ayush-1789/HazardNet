@echo off
echo Testing HazardNet API...
echo.

timeout /t 2 /nobreak >nul

echo Testing Health Endpoint...
curl -s http://localhost:3000/health
echo.
echo.

echo Testing Register Endpoint...
curl -s -X POST http://localhost:3000/api/auth/register -H "Content-Type: application/json" -d "{\"name\":\"Test User\",\"email\":\"test%random%@example.com\",\"password\":\"Test123!\",\"phone\":\"+1234567890\"}"
echo.
echo.

echo Testing Get Hazards...
curl -s "http://localhost:3000/api/hazards?latitude=40.7128&longitude=-74.0060&radius=5000"
echo.
echo.

echo Tests complete!
pause
