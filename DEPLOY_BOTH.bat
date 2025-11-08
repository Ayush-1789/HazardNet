@echo off
echo ========================================
echo  DEPLOY TO RAILWAY + AWS
echo  Triple Backend Deployment Script
echo ========================================
echo.

echo [STEP 1] Railway Deployment (5 minutes)
echo ========================================
echo.
echo Railway is EASIEST and FREE ($5/month credit)
echo.
echo 1. Go to: https://railway.app
echo 2. Sign in with GitHub
echo 3. Click "New Project"
echo 4. Select "Deploy from GitHub repo"
echo 5. Choose: Ayush-1789/HazardNet
echo 6. Set Root Directory: backend
echo 7. Add Environment Variables:
echo    - DATABASE_URL=postgresql://neondb_owner:npg_qD9xQKlUm1io@ep-purple-forest-a8zm9xmt-pooler.eastus2.azure.neon.tech/neondb?sslmode=require
echo    - JWT_SECRET=super-secret-jwt-key-change-in-production
echo    - NODE_ENV=production
echo 8. Click "Deploy"
echo 9. Copy your Railway URL
echo.
pause
echo.

echo [STEP 2] Update Railway URL in Code
echo ========================================
echo.
echo After Railway deploys, you'll get a URL like:
echo   https://hazardnet-production-xxx.up.railway.app
echo.
echo I'll help you update the code after you provide the URL.
echo.
set /p RAILWAY_URL="Paste your Railway URL here (or press Enter to skip): "
echo.

if not "%RAILWAY_URL%"=="" (
    echo Updating code with Railway URL: %RAILWAY_URL%
    echo.
    powershell -Command "(Get-Content 'lib\core\config\api_config.dart') -replace 'https://your-railway-url.up.railway.app', '%RAILWAY_URL%' | Set-Content 'lib\core\config\api_config.dart'"
    echo ✓ Railway URL updated!
    echo.
) else (
    echo Skipping Railway URL update for now.
    echo You can update it later in: lib\core\config\api_config.dart
    echo.
)

echo [STEP 3] AWS Deployment (15 minutes)
echo ========================================
echo.
echo AWS requires more setup but provides enterprise reliability.
echo.
echo OPTION A - Easy Way (Elastic Beanstalk Console):
echo   1. Go to: https://console.aws.amazon.com/elasticbeanstalk
echo   2. Click "Create Application"
echo   3. Platform: Node.js 18
echo   4. Upload backend folder as ZIP
echo   5. Add environment variables
echo   6. Deploy!
echo.
echo OPTION B - Command Line (Requires AWS CLI):
echo   Run: DEPLOY_TO_AWS.bat
echo.
choice /C YN /M "Do you want to deploy to AWS now"
if errorlevel 2 goto SkipAWS
if errorlevel 1 goto DeployAWS

:DeployAWS
echo.
echo Checking if AWS CLI is installed...
where aws >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo AWS CLI not found!
    echo.
    echo Install AWS CLI:
    echo   1. Download: https://awscli.amazonaws.com/AWSCLIV2.msi
    echo   2. Run installer
    echo   3. Restart this script
    echo.
    pause
    goto SkipAWS
)

echo AWS CLI found! Opening deployment script...
call DEPLOY_TO_AWS.bat
goto UpdateAWS

:SkipAWS
echo Skipping AWS deployment for now.
echo You can deploy later using: DEPLOY_TO_AWS.bat
echo.

:UpdateAWS
echo.
echo [STEP 4] Update AWS URL in Code
echo ========================================
echo.
echo After AWS deploys, you'll get a URL like:
echo   http://hazardnet-env.eba-xxx.us-east-1.elasticbeanstalk.com
echo.
set /p AWS_URL="Paste your AWS URL here (or press Enter to skip): "
echo.

if not "%AWS_URL%"=="" (
    echo Updating code with AWS URL: %AWS_URL%
    echo.
    powershell -Command "(Get-Content 'lib\core\config\api_config.dart') -replace 'https://your-aws-url.com', '%AWS_URL%' | Set-Content 'lib\core\config\api_config.dart'"
    echo ✓ AWS URL updated!
    echo.
) else (
    echo Skipping AWS URL update for now.
    echo You can update it later in: lib\core\config\api_config.dart
    echo.
)

echo [STEP 5] Push Updated Code
echo ========================================
echo.
if not "%RAILWAY_URL%"=="" if not "%AWS_URL%"=="" (
    echo Committing and pushing updated backend URLs...
    cd /d "%~dp0"
    git add lib/core/config/api_config.dart
    git commit -m "Update Railway and AWS backend URLs"
    git push
    echo.
    echo ✓ Code pushed! GitHub Actions will build new APK.
    echo.
) else (
    echo URLs not updated. Push code manually after adding URLs.
    echo.
)

echo ========================================
echo  DEPLOYMENT SUMMARY
echo ========================================
echo.
if not "%RAILWAY_URL%"=="" (
    echo ✓ Railway: %RAILWAY_URL%
) else (
    echo ⏱ Railway: Not deployed yet
)
echo.
if not "%AWS_URL%"=="" (
    echo ✓ AWS: %AWS_URL%
) else (
    echo ⏱ AWS: Not deployed yet
)
echo.
echo ✓ Laptop: http://192.168.31.39:3000/api
echo.
echo ========================================
echo  NEXT STEPS
echo ========================================
echo.
echo 1. Test each backend URL in browser:
echo    - Add /health to URL and check response
echo.
echo 2. Wait for GitHub Actions to build APK:
echo    - Go to: https://github.com/Ayush-1789/HazardNet/actions
echo    - Download APK when ready
echo.
echo 3. Install APK on phone and test!
echo    - App will auto-select best backend
echo    - Check backend status in app
echo.
echo ========================================
echo  USEFUL COMMANDS
echo ========================================
echo.
echo - Monitor Railway: railway logs
echo - Monitor AWS: eb logs
echo - Start Laptop Backend: START_BACKEND.bat
echo - Check Backend Health: Test URLs in browser
echo.
pause
