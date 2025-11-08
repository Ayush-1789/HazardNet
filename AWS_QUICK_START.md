# ☁️ AWS Elastic Beanstalk Deployment Guide

## ⚡ Quick Facts:
- **Time:** 15 minutes
- **Cost:** FREE for 12 months (t2.micro), then ~$15/month
- **Result:** Enterprise-grade backend at http://hazardnet.elasticbeanstalk.com

---

## 🎯 Deployment Options:

### OPTION A: AWS Console (Easier - Recommended)
### OPTION B: AWS CLI (Advanced)

---

## 📋 OPTION A: Deploy via AWS Console

### Step 1: Create AWS Account
1. Go to: https://aws.amazon.com
2. Click **"Create an AWS Account"**
3. Enter email, password, account name
4. Add payment method (free tier requires card, but won't charge)
5. Verify phone number
6. Select **"Free tier"** plan

### Step 2: Prepare Backend ZIP
1. Open File Explorer
2. Go to: `C:\Users\Hammad\OneDrive\Documents\HazardNet_2.0.11\backend`
3. Select ALL files in backend folder:
   - server.js
   - package.json
   - routes folder
   - uploads folder
   - .env file
   - etc.
4. Right-click → **"Send to"** → **"Compressed (zipped) folder"**
5. Name it: `hazardnet-backend.zip`

### Step 3: Go to Elastic Beanstalk
6. Login to AWS Console: https://console.aws.amazon.com
7. Search for **"Elastic Beanstalk"** in top search bar
8. Click **"Elastic Beanstalk"**

### Step 4: Create Application
9. Click **"Create Application"** (big orange button)
10. Fill in details:
    - **Application name:** HazardNet
    - **Platform:** Node.js
    - **Platform branch:** Node.js 18 running on 64bit Amazon Linux 2023
    - **Application code:** Upload your code
11. Click **"Choose file"** → Select `hazardnet-backend.zip`
12. Click **"Next"**

### Step 5: Configure Environment
13. **Environment name:** hazardnet-production
14. **Domain:** hazardnet (or your preferred subdomain)
15. Click **"Next"**

### Step 6: Service Access
16. Select **"Create new service role"**
17. EC2 key pair: Skip (not needed)
18. EC2 instance profile: Create new role
19. Click **"Next"**

### Step 7: Set Environment Properties
20. Scroll to **"Environment properties"** section
21. Click **"Add environment property"**
22. Add these THREE variables:

**Property 1:**
```
Name: DATABASE_URL
Value: postgresql://neondb_owner:npg_qD9xQKlUm1io@ep-purple-forest-a8zm9xmt-pooler.eastus2.azure.neon.tech/neondb?sslmode=require
```

**Property 2:**
```
Name: JWT_SECRET
Value: super-secret-jwt-key-change-in-production
```

**Property 3:**
```
Name: NODE_ENV
Value: production
```

23. Click **"Next"**

### Step 8: Configure Instance
24. **Instance type:** t2.micro (free tier eligible)
25. **Root volume type:** General Purpose (SSD)
26. **Size:** 10 GB
27. Click **"Next"**

### Step 9: Configure Updates & Monitoring
28. Keep defaults
29. Click **"Next"**

### Step 10: Review & Deploy
30. Review all settings
31. Click **"Submit"**
32. Wait 5-10 minutes for deployment

### Step 11: Get Your URL
33. After deployment, you'll see:
    - **Health:** Green checkmark ✓
    - **URL:** http://hazardnet-production.us-east-1.elasticbeanstalk.com
34. Click the URL to test
35. Add `/api/health` to verify backend

---

## 📋 OPTION B: Deploy via AWS CLI

### Step 1: Install AWS CLI
```powershell
# Download and run installer
Start-Process "https://awscli.amazonaws.com/AWSCLIV2.msi"
```

### Step 2: Install EB CLI
```powershell
pip install awsebcli
```

### Step 3: Configure AWS Credentials
```powershell
aws configure
```
Enter:
- AWS Access Key ID: (from AWS Console → Security Credentials)
- AWS Secret Access Key: (from AWS Console)
- Region: us-east-1
- Output format: json

### Step 4: Initialize Elastic Beanstalk
```powershell
cd backend
eb init
```
Select:
- Region: us-east-1
- Application name: HazardNet
- Platform: Node.js
- Platform version: Node.js 18
- CodeCommit: No
- SSH: No

### Step 5: Create Environment Variables File
Create `backend/.ebextensions/environment.config`:
```yaml
option_settings:
  aws:elasticbeanstalk:application:environment:
    DATABASE_URL: postgresql://neondb_owner:npg_qD9xQKlUm1io@ep-purple-forest-a8zm9xmt-pooler.eastus2.azure.neon.tech/neondb?sslmode=require
    JWT_SECRET: super-secret-jwt-key-change-in-production
    NODE_ENV: production
```

### Step 6: Deploy
```powershell
eb create hazardnet-production
```

### Step 7: Open Application
```powershell
eb open
```

---

## ✅ Verify Deployment:

### Test Health Endpoint:
```
http://your-aws-url.elasticbeanstalk.com/api/health
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

### After you get AWS URL:
1. Open: `lib/core/config/api_config.dart`
2. Find line 10: `static const String awsBackendUrl = ...`
3. Replace with your actual URL:
```dart
static const String awsBackendUrl = 'http://hazardnet-production.elasticbeanstalk.com/api';
```
4. Save and push to GitHub

---

## 💰 Cost Breakdown:

### Free Tier (12 months):
- **750 hours/month** of t2.micro instance (FREE)
- **5 GB** of storage (FREE)
- **25 GB** data transfer out (FREE)

Your app usage:
- Running 24/7 = 720 hours/month
- **YOU STAY IN FREE TIER!**

### After Free Tier:
- t2.micro instance: ~$10/month
- Storage: ~$1/month
- Data transfer: ~$4/month
- **Total: ~$15/month**

---

## 📊 Monitor Your Deployment:

### View Logs:
```powershell
eb logs
```

### Check Health:
```powershell
eb health
```

### View Status:
```powershell
eb status
```

### SSH into Instance:
```powershell
eb ssh
```

---

## 🔧 Update Your Application:

### Update code and redeploy:
```powershell
cd backend
git pull  # Get latest changes
eb deploy
```

---

## 🔐 Security Best Practices:

### 1. Enable HTTPS (Free SSL):
```powershell
eb config
```
Add load balancer with SSL certificate

### 2. Restrict Database Access:
- Add AWS IP to Neon IP whitelist
- Use security groups

### 3. Change JWT Secret:
```powershell
eb setenv JWT_SECRET=new-super-secret-key
```

---

## 🎯 Useful AWS Commands:

### View environment info:
```powershell
eb status
```

### View recent logs:
```powershell
eb logs --stream
```

### Terminate environment (CAREFUL!):
```powershell
eb terminate hazardnet-production
```

### List all environments:
```powershell
eb list
```

---

## 🔄 Auto-Deploy from GitHub:

### Setup AWS CodePipeline:
1. Go to AWS Console → CodePipeline
2. Create new pipeline
3. Connect to GitHub
4. Select Ayush-1789/HazardNet repo
5. Set deploy provider: Elastic Beanstalk
6. Now every push to GitHub auto-deploys!

---

## 📊 Scaling (If Needed):

### Auto-scaling configuration:
```powershell
eb scale 2  # Scale to 2 instances
```

### Or configure in console:
1. Go to Elastic Beanstalk
2. Click your environment
3. Configuration → Capacity
4. Set min/max instances

---

## 🎯 What You Get:

✅ **99.99% Uptime** - Enterprise reliability  
✅ **Auto-scaling** - Handles traffic spikes  
✅ **Load Balancing** - Distributes requests  
✅ **Monitoring** - CloudWatch integration  
✅ **Logs** - Centralized logging  
✅ **Security** - AWS security features  
✅ **Backups** - Automatic snapshots  
✅ **Support** - AWS support available  

---

## ⚠️ Important Notes:

### Before Deployment:
- ✅ Ensure backend/package.json has `"start": "node server.js"`
- ✅ Remove node_modules from ZIP
- ✅ Include .env file OR set env variables in AWS console
- ✅ Test locally first with `npm start`

### After Deployment:
- 🔍 Check logs for errors: `eb logs`
- 🌐 Test health endpoint: `/api/health`
- 📱 Update Flutter app with new URL
- 🚀 Push to GitHub to rebuild APK

---

## 🆘 Troubleshooting:

### Problem: Environment creation failed
**Fix:**
- Check logs: `eb logs`
- Verify package.json has start script
- Check environment variables are set

### Problem: "502 Bad Gateway"
**Fix:**
- Backend not starting correctly
- Check logs for errors
- Verify PORT environment variable

### Problem: Database connection failed
**Fix:**
- Check DATABASE_URL is correct
- Verify Neon database is accessible
- Check security groups allow outbound to Neon

---

## 🎉 Success!

Once deployed, your backend runs on AWS infrastructure!

**Your app now has:**
- ✅ Enterprise-grade infrastructure
- ✅ 99.99% uptime SLA
- ✅ Auto-scaling capability
- ✅ Professional reliability

**AWS = Your enterprise backend!** ☁️

---

## 📞 Need Help?

- AWS Docs: https://docs.aws.amazon.com/elasticbeanstalk
- AWS Support: https://console.aws.amazon.com/support
- AWS Forums: https://forums.aws.amazon.com

---

**Next:** Test your backend and update the Flutter app! 🚀
