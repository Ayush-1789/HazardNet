# Mobile Device Connection Guide 📱

## The Problem

When testing HazardNet on a **physical Android/iOS device**, it needs to connect to your backend server running on your PC. Unlike an emulator (which can use `localhost`), your phone needs your PC's **network IP address**.

---

## One-Time Network Setup ⚙️

### Step 1: Run the Setup Script (Once)

**Right-click and "Run as Administrator":**
```batch
SETUP_NETWORK_ACCESS.bat
```

This script does:
1. ✅ Sets your network to "Private" (allows local connections)
2. ✅ Enables Network Discovery in Windows Firewall
3. ✅ Adds firewall rule for port 3000 (backend server)

**You only need to run this ONCE per Windows installation.**

---

## Daily Testing Workflow 🔄

### Step 1: Start Your Backend
```batch
START_BACKEND.bat
```

You'll see output like:
```
🚀 HazardNet API Server running on:
   Local:   http://localhost:3000
   Network: http://10.193.102.33:3000
📊 Health check: http://10.193.102.33:3000/health
```

**Important:** Note the **Network** IP address (e.g., `10.193.102.33`)

---

### Step 2: Ensure Same WiFi Network

Both your PC and phone must be on the **same WiFi network**.

**On PC:**
```powershell
ipconfig
```
Look for your WiFi adapter's IPv4 address.

**On Phone:**
- Go to WiFi Settings
- Verify you're connected to the same network as your PC

---

### Step 3: Test Connection from Phone

**Open your phone's browser** and visit:
```
http://YOUR_PC_IP:3000/health
```
(Replace `YOUR_PC_IP` with the IP from Step 1)

**Expected Response:**
```json
{
  "status": "ok",
  "timestamp": "2025-11-09T10:30:00.000Z",
  "uptime": 123.45
}
```

✅ **If you see this:** Your network is configured correctly!
❌ **If it times out:** Run diagnostics (see below)

---

### Step 4: Update Flutter App (If Needed)

Your app already uses the correct configuration. The IP is automatically detected from your PC's network.

**No code changes needed!** Just run:
```bash
flutter run
```

The app will connect to `http://YOUR_PC_IP:3000/api` automatically.

---

## Troubleshooting 🔧

### Issue 1: Connection Timeout

**Symptoms:**
```
SocketException: Connection timed out
address = 10.193.102.33, port = 3000
```

**Solution:**
```batch
# Run diagnostics
DIAGNOSE_NETWORK.bat
```

This will check:
- ✅ Network profile (should be "Private")
- ✅ Firewall rule status
- ✅ Port 3000 is listening
- ✅ Your current IP address

**Common fixes:**
1. **Firewall blocking:** Run `SETUP_NETWORK_ACCESS.bat` as Admin
2. **Public network:** Change to Private in Windows Settings
3. **Different WiFi:** Ensure phone and PC on same network
4. **VPN active:** Disable VPN on PC or phone

---

### Issue 2: "Cannot Reach Server"

**Check backend is running:**
```batch
START_BACKEND.bat
```

**Check from PC browser:**
```
http://localhost:3000/health
```

If this works but phone can't connect, it's a firewall/network issue.

---

### Issue 3: IP Address Changed

Your PC's IP can change when you reconnect to WiFi.

**Quick check:**
```batch
DIAGNOSE_NETWORK.bat
```

Look for the new IP in the output. **No app changes needed** - the app automatically uses the current IP.

---

### Issue 4: Windows Firewall Still Blocking

**Temporary test (NOT recommended for daily use):**
1. Windows Security → Firewall & Network Protection
2. Click "Private networks"
3. Turn off firewall
4. Test if phone can connect
5. **Turn firewall back on!**
6. If it worked, the issue is firewall rules

**Permanent fix:**
```batch
# Remove old rule if exists
netsh advfirewall firewall delete rule name="HazardNet Backend Port 3000"

# Add new rule with all profiles
netsh advfirewall firewall add rule name="HazardNet Backend Port 3000" dir=in action=allow protocol=TCP localport=3000 profile=domain,private,public

# Verify
netsh advfirewall firewall show rule name="HazardNet Backend Port 3000"
```

---

## Alternative Solutions 🌐

### Option 1: Use Railway Deployment (Recommended for Testing)

Deploy to Railway (cloud) - no network setup needed:

**File:** `lib/core/config/api_config.dart`
```dart
// Change this line:
static String _currentBackendUrl = railwayBackendUrl; // Instead of laptopBackendUrl
```

**Deploy backend:**
```batch
DEPLOY_TO_AWS.bat
```

Now your app works **anywhere** without local network setup!

---

### Option 2: Use PC's Mobile Hotspot

**On PC:**
1. Settings → Network → Mobile Hotspot
2. Turn on "Share my internet connection"
3. Note the hotspot name and password

**On Phone:**
1. Connect to PC's hotspot
2. PC's IP will be: `192.168.137.1`

**Update backend startup:**
Your backend will automatically detect this IP.

---

### Option 3: Use ngrok (Temporary Public URL)

```bash
# Install ngrok
choco install ngrok

# Expose port 3000
ngrok http 3000
```

You'll get a URL like: `https://abc123.ngrok.io`

**Update Flutter:**
```dart
static const String baseApiUrl = 'https://abc123.ngrok.io/api';
```

**Note:** Free ngrok URLs expire when you close the terminal.

---

## Network Architecture 🏗️

### Local Development (What You're Doing)
```
[Phone] ──WiFi──> [Router] ──WiFi──> [PC:3000]
                     └─ Same Network ─┘
```

**Pros:**
- ✅ Fast (local network speed)
- ✅ No internet needed (after initial setup)
- ✅ Free
- ✅ Easy debugging

**Cons:**
- ❌ Requires same WiFi
- ❌ IP can change
- ❌ One-time firewall setup

---

### Cloud Deployment (Railway/AWS)
```
[Phone] ──Internet──> [Cloud Server:443]
```

**Pros:**
- ✅ Works anywhere
- ✅ No firewall setup
- ✅ Fixed URL
- ✅ HTTPS (secure)

**Cons:**
- ❌ Requires internet
- ❌ Slightly slower
- ❌ May have costs (free tiers available)

---

## Best Practice Workflow 💡

### For Development & Testing:
1. Use **local backend** (faster, easier debugging)
2. Run `SETUP_NETWORK_ACCESS.bat` once
3. Daily: Just run `START_BACKEND.bat` and `flutter run`

### For Demos & Sharing:
1. Deploy to **Railway** (stable, always accessible)
2. Share app with anyone
3. No network setup for users

### For Production:
1. Deploy to **AWS/Railway** with proper domain
2. Enable HTTPS
3. Use environment-based API URLs
4. Implement proper security

---

## Security Notes 🔒

### Local Network Setup:
- ✅ Firewall rule only allows port 3000
- ✅ Only devices on your WiFi can connect
- ✅ Safe for development

### What NOT to Do:
- ❌ Don't open port 3000 to the internet
- ❌ Don't disable entire Windows Firewall
- ❌ Don't use `0.0.0.0` in production without VPN
- ❌ Don't share your local IP publicly

---

## FAQ ❓

### Q: Do I need to run firewall setup every time?
**A:** No! Only once. The rule is permanent.

### Q: Why does my IP keep changing?
**A:** Your router assigns IPs dynamically. The app auto-detects the new IP.

### Q: Can I use USB debugging instead?
**A:** Yes! Use `adb reverse tcp:3000 tcp:3000` then use `http://localhost:3000` in the app.

### Q: Does this work with iOS?
**A:** Yes! Same setup, same workflow.

### Q: Can friends test my app?
**A:** Only if they're on your WiFi. For external testing, deploy to Railway.

### Q: Will this affect my cloud deployment?
**A:** No! Local setup and cloud deployment are independent.

---

## Quick Reference Commands 📋

```batch
# One-time setup (as Admin)
SETUP_NETWORK_ACCESS.bat

# Check if everything is configured
DIAGNOSE_NETWORK.bat

# Daily workflow
START_BACKEND.bat
flutter run

# Find your IP
ipconfig

# Test from phone browser
http://YOUR_IP:3000/health

# Deploy to cloud instead
DEPLOY_TO_AWS.bat
```

---

## Success Checklist ✅

Before testing on phone:
- [ ] Ran `SETUP_NETWORK_ACCESS.bat` as Admin (once)
- [ ] Backend is running (`START_BACKEND.bat`)
- [ ] Phone and PC on same WiFi
- [ ] Tested `http://YOUR_IP:3000/health` in phone browser
- [ ] Saw JSON response with "status": "ok"

If all checked, your app should work! 🎉

---

*This setup is permanent and doesn't affect your cloud deployment workflow.*
