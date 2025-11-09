@echo off
echo ========================================
echo HazardNet Network Access Setup
echo ========================================
echo.
echo This script will configure Windows to allow mobile devices
echo to connect to your backend server. Run this ONCE as Administrator.
echo.
pause

echo.
echo [1/4] Checking network profile...
powershell -Command "Get-NetConnectionProfile | Select-Object Name, NetworkCategory, InterfaceAlias"

echo.
echo [2/4] Setting network profile to Private...
powershell -Command "Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private"
if %errorlevel% neq 0 (
    echo.
    echo ⚠️  Could not change network profile automatically.
    echo 📝 Please do this manually:
    echo    1. Go to: Settings ^> Network ^& Internet ^> Wi-Fi
    echo    2. Click on your network name
    echo    3. Change "Network profile type" to "Private"
    echo.
    pause
)

echo.
echo [3/4] Enabling Network Discovery...
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes

echo.
echo [4/4] Verifying firewall rule for port 3000...
netsh advfirewall firewall show rule name="HazardNet Backend Port 3000" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Firewall rule already exists and is active
    netsh advfirewall firewall set rule name="HazardNet Backend Port 3000" new enable=yes profile=domain,private,public
) else (
    echo Adding firewall rule for all network profiles...
    netsh advfirewall firewall add rule name="HazardNet Backend Port 3000" dir=in action=allow protocol=TCP localport=3000 profile=domain,private,public
    echo ✅ Firewall rule added
)

echo.
echo ========================================
echo ✅ Setup Complete!
echo ========================================
echo.
echo Your mobile device should now be able to connect to:
echo http://YOUR_IP:3000
echo.
echo To find your IP address, run: ipconfig
echo Look for "IPv4 Address" under your WiFi adapter
echo.
echo 📱 Quick Test: Open your phone browser and visit:
echo    http://YOUR_IP:3000/health
echo.
pause
