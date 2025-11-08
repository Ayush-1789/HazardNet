# 🚂 Railway Deployment - Step-by-Step Guide

## ⚡ Quick Facts:
- **Time:** 5 minutes
- **Cost:** FREE ($5/month credit, renews monthly)
- **Result:** 24/7 cloud backend at https://your-app.up.railway.app

---

## 🎯 Step-by-Step Deployment:

### Step 1: Go to Railway
1. Open browser: https://railway.app
2. Click **"Login"** (top right)
3. Select **"Login with GitHub"**
4. Authorize Railway to access your repos

### Step 2: Create New Project
5. Click **"New Project"** (big button)
6. Select **"Deploy from GitHub repo"**
7. Find and click: **Ayush-1789/HazardNet**
8. Click **"Deploy Now"**

### Step 3: Configure Root Directory
9. Wait for initial deploy (will fail - that's okay!)
10. Click **"Settings"** tab (left sidebar)
11. Find **"Root Directory"** section
12. Enter: `backend`
13. Click **"Save"**

### Step 4: Set Start Command
14. Still in **Settings** tab
15. Find **"Start Command"** section
16. Enter: `npm start`
17. Click **"Save"**

### Step 5: Add Environment Variables
18. Click **"Variables"** tab (left sidebar)
19. Click **"New Variable"**
20. Add these THREE variables:

**Variable 1:**
```
Name: DATABASE_URL
Value: postgresql://neondb_owner:npg_qD9xQKlUm1io@ep-purple-forest-a8zm9xmt-pooler.eastus2.azure.neon.tech/neondb?sslmode=require
```

**Variable 2:**
```
Name: JWT_SECRET
Value: super-secret-jwt-key-change-in-production
```

**Variable 3:**
```
Name: NODE_ENV
Value: production
```

21. Click **"Add"** after each variable

### Step 6: Redeploy
22. Click **"Deployments"** tab
23. Click **"Deploy"** button (or wait for auto-redeploy)
24. Wait 2-3 minutes for build to complete

### Step 7: Get Your URL
25. Look for **"Domains"** section (right side)
26. You'll see a URL like: `hazardnet-production-xxx.up.railway.app`
27. Click the URL to test (add `/api/health` to test endpoint)
28. Copy the URL (you'll need it!)

---

## ✅ Verify Deployment:

### Test Health Endpoint:
```
Open browser: https://your-railway-url.up.railway.app/api/health
```

**Expected Response:**
```json
{
  "status": "ok",
  "timestamp": "2025-11-08T...",
  "database": "connected"
}
```

---

## 🔄 Update Flutter App:

### After you get Railway URL:
1. Open: `lib/core/config/api_config.dart`
2. Find line 9: `static const String railwayBackendUrl = ...`
3. Replace with your actual URL:
```dart
static const String railwayBackendUrl = 'https://hazardnet-production-xxx.up.railway.app/api';
```
4. Save file
5. Run deployment script to push changes

---

## 💰 Cost Breakdown:

Railway gives you:
- **$5 FREE credit per month** (renews automatically)
- **No credit card required**
- **Enough for 500+ hours** of uptime

Your app usage:
- Running 24/7 = 720 hours/month
- Cost = ~$2/month
- **YOU STAY FREE!** ($5 credit covers it)

---

## 📊 Monitor Your Deployment:

### View Logs:
1. Go to Railway dashboard
2. Click your project
3. Click **"Deployments"** tab
4. Click **"View Logs"**

### Check Metrics:
1. Click **"Metrics"** tab
2. See CPU, Memory, Network usage
3. Monitor your $5 credit usage

---

## 🔧 Troubleshooting:

### Problem: Deploy failed
**Fix:**
- Check Root Directory is set to `backend`
- Check Start Command is `npm start`
- Check all 3 environment variables are added

### Problem: "Application Error"
**Fix:**
- Click "View Logs" to see error
- Usually missing environment variables
- Or wrong DATABASE_URL

### Problem: Can't connect from app
**Fix:**
- Add `/api/health` to URL and test in browser
- Make sure you updated `api_config.dart` with correct URL
- Check URL doesn't have trailing slash

---

## 🚀 Auto-Deploy from GitHub:

Railway automatically redeploys when you push to GitHub!

Every time you:
```bash
git push origin main
```

Railway will:
1. Detect the push
2. Build your backend
3. Deploy automatically
4. Update live site

**No manual deployment needed!** 🎉

---

## 📝 Useful Railway Commands:

### Install Railway CLI (Optional):
```bash
npm install -g @railway/cli
```

### Login:
```bash
railway login
```

### View Logs:
```bash
railway logs
```

### Open Dashboard:
```bash
railway open
```

---

## 🎯 What You Get:

✅ **24/7 Availability** - Never goes offline  
✅ **Free Hosting** - $5 credit covers your usage  
✅ **Auto SSL** - Automatic HTTPS  
✅ **Auto Deploy** - Push to GitHub = Deploy  
✅ **Global CDN** - Fast worldwide  
✅ **Monitoring** - Built-in metrics  
✅ **Logs** - Real-time log viewing  
✅ **Scaling** - Automatic if you need it  

---

## 🎉 Success!

Once deployed, your backend runs 24/7 on Railway!

**Your app now works even when:**
- ✅ Laptop is OFF
- ✅ You're away from home
- ✅ Judges want to test
- ✅ Friends want to try

**Railway = Your FREE cloud backend!** 🚂

---

## 📞 Need Help?

- Railway Docs: https://docs.railway.app
- Railway Discord: https://discord.gg/railway
- Railway Status: https://status.railway.app

---

**Next:** Update your Flutter app with the Railway URL and redeploy! 🚀
