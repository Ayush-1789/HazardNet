@echo off
echo ========================================
echo HazardNet Backend - Quick Setup
echo ========================================
echo.

echo Current Status:
echo   [X] Backend files created
echo   [X] Dependencies installed
echo   [ ] Database configured
echo   [ ] Backend running
echo.

echo ========================================
echo WHAT YOU NEED TO DO:
echo ========================================
echo.

echo 1. Setup Neon Database (5 minutes)
echo    - Go to: https://neon.tech
echo    - Create free account
echo    - Create project: HazardNet
echo    - Run database/schema.sql in SQL Editor
echo    - Copy connection string
echo.

echo 2. Configure Backend (1 minute)
echo    - Open: backend\.env
echo    - Paste your connection string
echo.

echo 3. Start Backend (Run this)
echo    - cd backend
echo    - npm run dev
echo.

echo 4. Test Backend (New terminal)
echo    - curl http://localhost:3000/health
echo.

echo ========================================
echo For detailed instructions, read:
echo   START_HERE.md
echo ========================================
echo.

pause
