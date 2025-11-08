@echo off
color 0A
echo ========================================
echo  Starting HazardNet Backend Server
echo ========================================
echo.
echo ⚠️  IMPORTANT: DO NOT CLOSE THIS WINDOW!
echo.
echo Your mobile app needs this server to work.
echo Keep this window open while using the app.
echo.
echo Backend will be available at:
echo   - Local:   http://localhost:3000
echo   - Network: http://192.168.31.39:3000
echo   - Mobile:  http://192.168.31.39:3000/api
echo.
echo ✅ Make sure your phone is on the same WiFi!
echo ✅ Keep your laptop ON and connected!
echo.
echo ========================================
cd backend
node server.js
echo.
echo ❌ Server stopped! Mobile app will not work.
pause
