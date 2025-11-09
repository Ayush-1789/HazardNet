@echo off
echo ========================================
echo HazardNet Network Diagnostics
echo ========================================
echo.

echo [Check 1] Network Profile
echo ----------------------------------------
powershell -Command "Get-NetConnectionProfile | Select-Object Name, NetworkCategory, InterfaceAlias"
echo.

echo [Check 2] IPv4 Address
echo ----------------------------------------
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4 Address"') do (
    echo Mobile devices should connect to: http:%%a:3000
)
echo.

echo [Check 3] Firewall Rule Status
echo ----------------------------------------
netsh advfirewall firewall show rule name="HazardNet Backend Port 3000" | findstr /c:"Enabled" /c:"Direction" /c:"Profiles" /c:"LocalPort"
echo.

echo [Check 4] Port 3000 Listening Status
echo ----------------------------------------
netstat -ano | findstr :3000
echo.

echo [Check 5] Windows Firewall Status
echo ----------------------------------------
netsh advfirewall show currentprofile state
echo.

echo ========================================
echo Diagnostics Complete
echo ========================================
echo.
echo If port 3000 is not showing as LISTENING,
echo start your backend with: START_BACKEND.bat
echo.
pause
