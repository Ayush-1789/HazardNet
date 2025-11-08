@echo off
color 0B
echo ========================================
echo   AWS Backend Deployment Helper
echo ========================================
echo.
echo This will deploy your HazardNet backend to AWS Elastic Beanstalk
echo.
echo Prerequisites:
echo   1. AWS Account with free tier credits
echo   2. AWS CLI installed
echo   3. EB CLI installed
echo.
echo ========================================
echo.

:MENU
echo Choose an option:
echo.
echo 1. Install AWS CLI and EB CLI
echo 2. Configure AWS credentials
echo 3. Deploy to AWS (First time)
echo 4. Update existing AWS deployment
echo 5. View AWS backend logs
echo 6. Check AWS backend status
echo 7. Set environment variables
echo 8. Open AWS Console
echo 9. Terminate AWS deployment
echo 0. Exit
echo.

set /p choice="Enter your choice (0-9): "

if "%choice%"=="1" goto INSTALL
if "%choice%"=="2" goto CONFIGURE
if "%choice%"=="3" goto DEPLOY
if "%choice%"=="4" goto UPDATE
if "%choice%"=="5" goto LOGS
if "%choice%"=="6" goto STATUS
if "%choice%"=="7" goto SETENV
if "%choice%"=="8" goto CONSOLE
if "%choice%"=="9" goto TERMINATE
if "%choice%"=="0" goto EXIT

echo Invalid choice!
goto MENU

:INSTALL
echo.
echo Installing AWS CLI and EB CLI...
echo.
echo Step 1: Installing AWS CLI...
winget install Amazon.AWSCLI
echo.
echo Step 2: Installing EB CLI...
pip install awsebcli --upgrade --user
echo.
echo Done! Please restart this script.
pause
goto MENU

:CONFIGURE
echo.
echo Configuring AWS credentials...
echo.
echo You need:
echo   - AWS Access Key ID
echo   - AWS Secret Access Key
echo.
echo Get these from: AWS Console ^> IAM ^> Users ^> Security Credentials
echo.
aws configure
echo.
echo Configuration complete!
pause
goto MENU

:DEPLOY
echo.
echo Deploying to AWS Elastic Beanstalk (First time)...
echo.
cd backend
echo Step 1: Initializing EB application...
eb init -p node.js-18 hazardnet-backend --region us-east-1
echo.
echo Step 2: Creating environment (this may take 5-10 minutes)...
eb create hazardnet-production --instance-type t2.micro --single
echo.
echo Step 3: Setting environment variables...
echo.
set /p DB_URL="Enter your Neon DATABASE_URL: "
set /p JWT_SECRET="Enter your JWT_SECRET: "
eb setenv DATABASE_URL="%DB_URL%"
eb setenv JWT_SECRET="%JWT_SECRET%"
eb setenv NODE_ENV="production"
echo.
echo Deployment complete!
echo.
echo Your backend URL will be shown above (something like: hazardnet-production.us-east-1.elasticbeanstalk.com)
echo.
echo Copy that URL and update it in: lib\core\config\api_config.dart
echo.
pause
goto MENU

:UPDATE
echo.
echo Updating AWS deployment...
echo.
cd backend
eb deploy
echo.
echo Update complete!
pause
goto MENU

:LOGS
echo.
echo Fetching AWS backend logs...
echo.
cd backend
eb logs
pause
goto MENU

:STATUS
echo.
echo Checking AWS backend status...
echo.
cd backend
eb status
pause
goto MENU

:SETENV
echo.
echo Setting environment variables...
echo.
cd backend
set /p VAR_NAME="Enter variable name (e.g., DATABASE_URL): "
set /p VAR_VALUE="Enter variable value: "
eb setenv %VAR_NAME%="%VAR_VALUE%"
echo.
echo Variable set!
pause
goto MENU

:CONSOLE
echo.
echo Opening AWS backend in browser...
cd backend
eb open
pause
goto MENU

:TERMINATE
echo.
echo ========================================
echo   WARNING: This will delete everything!
echo ========================================
echo.
set /p confirm="Are you sure? (yes/no): "
if /i "%confirm%"=="yes" (
    cd backend
    eb terminate hazardnet-production
    echo.
    echo AWS deployment terminated.
) else (
    echo Cancelled.
)
pause
goto MENU

:EXIT
echo.
echo Goodbye!
exit
