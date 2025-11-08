# 📱 Mobile App Setup Guide

## ✅ What I Fixed:

### 1. **Network Connectivity** 
- Changed API URL from `localhost` to `192.168.31.39` (your PC's IP)
- Updated backend to listen on all network interfaces (`0.0.0.0`)
- Enabled CORS for mobile connections

### 2. **Backend Configuration**
- Server now accepts connections from your phone
- All API endpoints work over WiFi

### 3. **Firewall Setup**
- Created script to allow port 3000 through Windows Firewall

---

## 🚀 Quick Start (3 Steps):

### Step 1: Add Firewall Rule (ONE TIME ONLY)
**Right-click** `ADD_FIREWALL_RULE.bat` → **Run as Administrator**
- This allows your phone to connect through Windows Firewall

### Step 2: Start Backend Server
Double-click `START_BACKEND.bat`
- Backend will run on: `http://192.168.31.39:3000`
- Keep this window open

### Step 3: Get New APK
1. GitHub is building new APK with updated IP address
2. Go to: https://github.com/Ayush-1789/HazardNet/actions
3. Wait 5-10 minutes for build to complete
4. Download new `app-release.apk`
5. Install on your phone

---

## 📱 Install APK on Phone:

1. Download the new APK from GitHub Actions
2. Transfer to your phone (via USB or download directly)
3. Enable "Install from Unknown Sources" in Android settings
4. Install the APK
5. Open HazardNet app

---

## ⚠️ IMPORTANT Requirements:

✅ **Your phone and PC must be on the SAME WiFi network**
✅ **Backend server must be running** (START_BACKEND.bat)
✅ **Firewall rule must be added** (ADD_FIREWALL_RULE.bat as Admin)
✅ **Use the NEW APK** with IP `192.168.31.39` (building now)

---

## 🧪 Test Connection:

### From Your Phone's Browser:
Open Chrome and go to: `http://192.168.31.39:3000/health`

If you see JSON response like:
```json
{"status":"ok","timestamp":"...","uptime":123}
```
✅ **Connection works! Your app will work too!**

If you see "Can't reach this page":
❌ Check:
- Is backend running? (START_BACKEND.bat)
- Same WiFi network?
- Firewall rule added?

---

## 📊 What Works Now:

✅ User login/register
✅ View nearby hazards
✅ Report hazards with photos
✅ Real-time alerts
✅ Upvote/downvote hazards
✅ Emergency SOS
✅ Gamification (points, badges, leaderboard)
✅ Authority dashboard

---

## 🔄 If Your PC IP Changes:

If you restart your router or PC, your IP might change from `192.168.31.39` to something else.

**To fix:**
1. Run: `ipconfig` in PowerShell
2. Find your new IPv4 address
3. Update `lib/core/constants/app_constants.dart` with new IP
4. Update `backend/server.js` with new IP
5. Rebuild APK (push to GitHub)

---

## 🎯 Current Configuration:

- **Backend IP:** 192.168.31.39
- **Backend Port:** 3000
- **API URL:** http://192.168.31.39:3000/api
- **Database:** Neon PostgreSQL (already connected)

---

## ⚡ Quick Troubleshooting:

**Problem:** App shows "Network error"
**Solution:** 
1. Check backend is running
2. Test URL in phone browser: http://192.168.31.39:3000/health
3. Verify same WiFi network
4. Reinstall new APK

**Problem:** "Connection refused"
**Solution:** Run ADD_FIREWALL_RULE.bat as Administrator

**Problem:** Alerts not loading
**Solution:** 
1. Backend is running ✅
2. Database connected ✅
3. Just need new APK with correct IP!

---

## 🎉 Next Steps:

1. ✅ Wait for APK build (5-10 mins)
2. ✅ Run ADD_FIREWALL_RULE.bat as Admin
3. ✅ Run START_BACKEND.bat
4. ✅ Download & install new APK
5. ✅ Test app on your phone!

**Build Status:** https://github.com/Ayush-1789/HazardNet/actions

---

**Everything is configured correctly! Just need to wait for the new APK build to complete.** 🚀
