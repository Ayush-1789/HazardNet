@echo off
echo Adding Windows Firewall rule for HazardNet Backend...
netsh advfirewall firewall add rule name="HazardNet Backend Port 3000" dir=in action=allow protocol=TCP localport=3000
echo.
echo Firewall rule added successfully!
echo Your mobile device can now connect to the backend.
pause
