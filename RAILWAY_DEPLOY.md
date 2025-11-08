# 🚂 Deploy to Railway - FREE Forever!

## Why Railway?
- ✅ **FREE** ($5 credit/month, renews monthly - enough for 24/7!)
- ✅ **Easy** - One command deployment
- ✅ **Fast** - Deploy in 2 minutes
- ✅ **No credit card** required for free tier
- ✅ **Auto HTTPS** - Get free SSL certificate
- ✅ **Always on** - No sleep/wake delays

---

## 🚀 Quick Deploy (3 Steps):

### Step 1: Connect GitHub to Railway

1. Go to: https://railway.app
2. Click "Start a New Project"
3. Click "Deploy from GitHub repo"
4. Select: **Ayush-1789/HazardNet**
5. Railway will auto-detect Node.js project

### Step 2: Configure Environment Variables

In Railway dashboard, add these variables:

```
DATABASE_URL=postgresql://neondb_owner:npg_qD9xQKlUm1io@ep-purple-forest-a8zm9xmt-pooler.eastus2.azure.neon.tech/neondb?sslmode=require

JWT_SECRET=change-this-to-a-very-long-random-secret-key-for-production

NODE_ENV=production

PORT=3000
```

### Step 3: Set Root Directory

1. In Railway dashboard → Settings
2. Set **Root Directory** to: `backend`
3. Set **Start Command** to: `npm start`
4. Click "Deploy"

---

## 📱 Get Your Railway URL

After deployment (takes 2 mins):
1. Click "View Deployment"
2. Copy your URL: `https://hazardnet-production.up.railway.app`
3. Update `lib/core/config/api_config.dart` line 9:

```dart
static const String railwayBackendUrl = 'https://hazardnet-production.up.railway.app/api';
```

4. Commit and push → New APK builds automatically!

---

## ✅ That's It!

Your app now has **THREE backends**:

Priority 1: **Laptop** → Tries first (fastest)
Priority 2: **Railway** → Free cloud backup
Priority 3: **AWS** → Optional extra backup

App automatically uses the best available backend!

---

## 💰 Cost:

**Railway Free Tier:**
- $5 credit per month (resets monthly)
- Enough for ~500 hours of runtime
- Perfect for small apps
- No credit card needed

**Your Usage:**
- Small Node.js app: ~$0.01/hour
- = ~$7.20/month full 24/7
- But you get $5 free!
- **Actual cost: ~$2/month**

---

## 🔄 Auto-Deploy:

Railway watches your GitHub repo!
- Push to `main` branch
- Railway auto-deploys
- No manual steps needed

---

## 📊 Monitor Your App:

Railway dashboard shows:
- ✅ Deployment status
- ✅ Logs in real-time
- ✅ Resource usage
- ✅ Cost tracking

---

## 🎯 Current Architecture:

```
📱 Phone App
    ↓
    ├─ Try Laptop (192.168.31.39) → ✅ Fast & Free
    ↓ (if fails in 3s)
    ├─ Try Railway (up.railway.app) → ✅ Free Cloud
    ↓ (if fails in 3s)
    └─ Try AWS (elasticbeanstalk) → ✅ Paid Backup
```

**Triple redundancy = Maximum reliability!** 🚀
