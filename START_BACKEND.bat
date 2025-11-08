@echo off
echo ========================================
echo  Starting HazardNet Backend Server
echo ========================================
echo.
echo Backend will be available at:
echo   - Local:   http://localhost:3000
echo   - Network: http://192.168.31.39:3000
echo   - Mobile:  http://192.168.31.39:3000/api
echo.
echo Make sure your phone is on the same WiFi!
echo.
cd backend
node server.js
pause
