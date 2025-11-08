# 🚀 QUICK DEPLOY - Both Railway & AWS

## ⚠️ Railway CLI Issue Detected
Your Railway account has hit the **free tier project limit** (1-2 projects max).

**Solutions:**
1. **Use Railway Web Interface** (RECOMMENDED - Takes 3 minutes)
2. Delete existing "electric-form" project if not needed
3. Upgrade Railway account ($5/month - you get $5 credit free)

---

## 🚂 OPTION 1: Deploy to Railway (Web Interface)

### Step 1: Go to Railway
Open: https://railway.app/dashboard

### Step 2: Create New Project
1. Click **"New Project"**
2. Select **"Deploy from GitHub repo"**
3. Choose: **Ayush-1789/HazardNet**

### Step 3: Configure
```
Root Directory: backend
Start Command: npm start
```

### Step 4: Add Environment Variables
Click **"Variables"** tab, add:

```env
DATABASE_URL=postgresql://neondb_owner:npg_qD9xQKlUm1io@ep-purple-forest-a8zm9xmt-pooler.eastus2.azure.neon.tech/neondb?sslmode=require

JWT_SECRET=super-secret-jwt-key-change-in-production-hazardnet-2024

NODE_ENV=production

PORT=3000
```

### Step 5: Deploy
1. Click **"Deploy"**
2. Wait 2-3 minutes
3. Copy your URL (e.g., `hazardnet-backend-production.up.railway.app`)

### Step 6: Update Flutter App
1. Open `lib/core/config/api_config.dart`
2. Line 9: Update Railway URL:
   ```dart
   static const String railwayBackendUrl = 'https://YOUR-RAILWAY-URL.up.railway.app/api';
   ```
3. Commit and push to GitHub

✅ **DONE! Railway deployed in 3 minutes!**

---

## ☁️ OPTION 2: Deploy to AWS (Web Console)

### Step 1: Prepare Deployment Package
Run this in PowerShell:

```powershell
cd c:\Users\Hammad\OneDrive\Documents\HazardNet_2.0.11\backend
Compress-Archive -Path * -DestinationPath ..\hazardnet-backend.zip -Force
```

### Step 2: Go to AWS Elastic Beanstalk
1. Open: https://console.aws.amazon.com/elasticbeanstalk
2. Click **"Create Application"**

### Step 3: Configure Application
```
Application name: HazardNet-Backend
Platform: Node.js
Platform branch: Node.js 18 running on 64bit Amazon Linux 2023
Platform version: (Latest)
```

### Step 4: Upload Code
1. Select **"Upload your code"**
2. Upload: `hazardnet-backend.zip`
3. Click **"Create application"**

### Step 5: Configure Environment Variables
After deployment:
1. Go to **Configuration** → **Software**
2. Add environment properties:

```env
DATABASE_URL=postgresql://neondb_owner:npg_qD9xQKlUm1io@ep-purple-forest-a8zm9xmt-pooler.eastus2.azure.neon.tech/neondb?sslmode=require

JWT_SECRET=super-secret-jwt-key-change-in-production-hazardnet-2024

NODE_ENV=production

PORT=3000
```

3. Click **"Apply"**

### Step 6: Get URL & Update App
1. Copy your AWS URL (e.g., `hazardnet-backend.us-east-1.elasticbeanstalk.com`)
2. Open `lib/core/config/api_config.dart`
3. Line 12: Update AWS URL:
   ```dart
   static const String awsBackendUrl = 'https://YOUR-AWS-URL.elasticbeanstalk.com/api';
   ```
4. Commit and push to GitHub

✅ **DONE! AWS deployed in 10 minutes!**

---

## 🎯 FASTEST PATH (Recommended):

### For Right Now:
```
1. Deploy to Railway via Web (3 mins) ✅ FREE
2. Skip AWS for now (uses credits)
```

### Why Railway First?
- ✅ FREE ($5 credit/month)
- ✅ Faster deployment (3 mins vs 10 mins)
- ✅ No credit card needed
- ✅ Auto-redeploy on GitHub push
- ✅ Perfect for competition

### Add AWS Later?
- Only if you need extra redundancy
- Only if you have AWS credits
- Railway alone is enough for competition!

---

## 📋 Quick Checklist:

**Railway Deployment:**
- [ ] Go to railway.app
- [ ] Create project from GitHub
- [ ] Set root directory: `backend`
- [ ] Add 4 environment variables
- [ ] Deploy and copy URL
- [ ] Update `api_config.dart` line 9
- [ ] Push to GitHub
- [ ] ✅ Done!

**AWS Deployment (Optional):**
- [ ] Create zip: `Compress-Archive -Path * -DestinationPath ..\hazardnet-backend.zip`
- [ ] Go to AWS Elastic Beanstalk console
- [ ] Create application (Node.js 18)
- [ ] Upload zip file
- [ ] Add environment variables
- [ ] Copy URL and update `api_config.dart` line 12
- [ ] Push to GitHub
- [ ] ✅ Done!

---

## 🚨 Railway Project Limit Issue:

You currently have: **electric-form** project

**Option A:** Delete it (if not needed)
```
1. Go to railway.app/dashboard
2. Click "electric-form"
3. Settings → Delete Project
4. Then try Railway CLI again
```

**Option B:** Use web interface (easier!)
- No CLI needed
- Deploy directly from GitHub
- Same result, easier process

---

## 💡 After Deployment:

### Test Your Backends:
```powershell
# Test Railway
curl https://YOUR-RAILWAY-URL.up.railway.app/health

# Test AWS
curl https://YOUR-AWS-URL.elasticbeanstalk.com/health
```

### Update Flutter App URLs:
Open: `lib/core/config/api_config.dart`

```dart
class ApiConfig {
  // Priority 1: Laptop (fastest when ON)
  static const String laptopBackendUrl = 'http://192.168.31.39:3000/api';
  
  // Priority 2: Railway (FREE 24/7 cloud)
  static const String railwayBackendUrl = 'https://YOUR-ACTUAL-RAILWAY-URL.up.railway.app/api';
  
  // Priority 3: AWS (backup cloud)
  static const String awsBackendUrl = 'https://YOUR-ACTUAL-AWS-URL.elasticbeanstalk.com/api';
  
  // ... rest of code
}
```

### Rebuild APK:
```bash
git add .
git commit -m "Update backend URLs with Railway and AWS"
git push origin main
```

GitHub Actions will auto-build new APK with triple backend! 🎉

---

## 📊 Deployment Status:

| Backend | Status | Speed | Cost | Deployment |
|---------|--------|-------|------|------------|
| 💻 Laptop | ✅ Ready | ⚡⚡⚡ | FREE | Already running |
| 🚂 Railway | ⏱️ Web Deploy | ⚡⚡ | FREE | 3 minutes |
| ☁️ AWS | 📋 Optional | ⚡⚡ | Credits | 10 minutes |

---

**Next Action:** Deploy to Railway via web interface (3 minutes) → Update URLs → Push to GitHub → ✅ Triple backend live!
