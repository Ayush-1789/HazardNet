# 🔧 Quick Fix: Connection Timeout Issue

## The Problem

Your network is set to "**Public**" which blocks local device connections. This is why your phone can't reach the backend server.

---

## ⚡ Solution (Choose One)

### Option 1: Change Network to Private (Recommended - 30 seconds)

**Manual Steps:**
1. Press `Win + I` to open Settings
2. Click `Network & Internet`
3. Click `Wi-Fi` (on the left)
4. Click on your network name: **"iQOO Neo 6 14"**
5. Under "Network profile type", select **Private**
6. Close Settings
7. **Restart your backend** (`START_BACKEND.bat`)
8. **Test on phone** - visit: `http://10.193.102.33:3000/health`

**Done!** Your phone should now connect. ✅

---

### Option 2: Update Firewall for Public Networks (If Option 1 Doesn't Work)

**Run PowerShell as Administrator:**
```powershell
netsh advfirewall firewall set rule name="HazardNet Backend Port 3000" new enable=yes profile=domain,private,public
```

This allows port 3000 on **all** network types including Public.

---

## ✅ Verify It's Fixed

**On your phone's browser:**
```
http://10.193.102.33:3000/health
```

**Expected response:**
```json
{
  "status": "ok",
  "timestamp": "2025-11-09T...",
  "uptime": 123.45
}
```

If you see this, **you're good to go!** 🎉

Then test the Flutter app:
```bash
flutter run
```

---

## Why This Happened

Windows has three network types:
- **Private** - Home/work networks (allows local connections) ✅
- **Public** - Coffee shops, airports (blocks local connections for security) ⛔
- **Domain** - Corporate networks

Your WiFi connection (iQOO Neo 6 14 hotspot) was automatically detected as **Public** by Windows.

---

## Will This Fix Persist?

**Option 1 (Change to Private):** 
- ✅ Yes, Windows remembers this network as Private
- ✅ Will work every time you connect to this hotspot
- ✅ Recommended for home/trusted networks

**Option 2 (Update Firewall):**
- ✅ Yes, firewall rule is permanent
- ⚠️ Less secure (allows connections even on public WiFi)
- ⚠️ Only use if Option 1 doesn't work

---

## Future Connections

**When you connect to the same WiFi again:**
- ✅ No setup needed
- ✅ Just run `START_BACKEND.bat`
- ✅ App connects automatically

**When you connect to a NEW WiFi:**
- 🔄 Change that network to "Private" (same steps)
- 🔄 Or firewall rule will already allow it (if you used Option 2)

---

## Alternative: Use Cloud Backend (No Setup Needed)

If you don't want to deal with network setup:

**Deploy to Railway:**
```batch
DEPLOY_TO_AWS.bat
```

**Update Flutter to use cloud:**  
Edit `lib/core/config/api_config.dart`:
```dart
static String _currentBackendUrl = railwayBackendUrl;
```

**Rebuild app:**
```bash
flutter run
```

Now your app works **anywhere** without local network setup! 🌐

---

## Summary

**Quick fix right now:**
1. Settings → Network & Internet → Wi-Fi → iQOO Neo 6 14 → Change to "Private"
2. Restart backend
3. Test on phone
4. Done!

**This is a ONE-TIME setup** for each WiFi network you use. ✅
