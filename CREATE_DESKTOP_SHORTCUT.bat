@echo off
echo Creating desktop shortcut for HazardNet Backend...

set SCRIPT_DIR=%~dp0
set DESKTOP=%USERPROFILE%\Desktop

powershell -Command "$WS = New-Object -ComObject WScript.Shell; $SC = $WS.CreateShortcut('%DESKTOP%\Start HazardNet Backend.lnk'); $SC.TargetPath = '%SCRIPT_DIR%START_BACKEND.bat'; $SC.WorkingDirectory = '%SCRIPT_DIR%'; $SC.IconLocation = 'shell32.dll,165'; $SC.Description = 'Start HazardNet Backend Server - Keep this running while using mobile app'; $SC.Save()"

echo.
echo ✅ Shortcut created on your Desktop!
echo.
echo You can now start the backend by clicking:
echo "Start HazardNet Backend" on your desktop
echo.
pause
