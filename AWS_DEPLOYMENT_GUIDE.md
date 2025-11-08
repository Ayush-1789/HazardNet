# AWS Deployment Guide for HazardNet Backend

## 🚀 Deploy Backend to AWS (Free Tier)

This guide will help you deploy your backend to AWS Elastic Beanstalk using your AWS free tier credits.

---

## 📋 Prerequisites

1. ✅ AWS Account with free tier credits
2. ✅ AWS CLI installed
3. ✅ EB CLI (Elastic Beanstalk CLI) installed

---

## 🔧 Step 1: Install AWS CLI & EB CLI

### Windows (PowerShell):

```powershell
# Install AWS CLI
winget install Amazon.AWSCLI

# Install EB CLI
pip install awsebcli --upgrade --user
```

### Verify Installation:
```bash
aws --version
eb --version
```

---

## 🔑 Step 2: Configure AWS Credentials

```bash
aws configure
```

Enter your:
- AWS Access Key ID
- AWS Secret Access Key  
- Default region: `us-east-1` (or your preferred region)
- Default output format: `json`

---

## 📦 Step 3: Prepare Backend for Deployment

Already configured in your project:
- ✅ `.ebextensions/nodecommand.config` - EB configuration
- ✅ `package.json` - Dependencies listed
- ✅ `.gitignore` - Proper exclusions

---

## 🚀 Step 4: Deploy to AWS Elastic Beanstalk

### From backend folder:

```bash
cd backend

# Initialize EB application
eb init -p node.js-18 hazardnet-backend --region us-east-1

# Create environment (uses free tier t2.micro)
eb create hazardnet-production --instance-type t2.micro --single

# This will:
# 1. Create EC2 instance (t2.micro - free tier)
# 2. Install Node.js
# 3. Deploy your backend
# 4. Set up load balancer
# 5. Give you a URL like: hazardnet-production.us-east-1.elasticbeanstalk.com
```

---

## 🔐 Step 5: Set Environment Variables

You need to add your Neon database URL to AWS:

```bash
# Set database URL
eb setenv DATABASE_URL="postgresql://neondb_owner:npg_qD9xQKlUm1io@ep-purple-forest-a8zm9xmt-pooler.eastus2.azure.neon.tech/neondb?sslmode=require"

# Set JWT secret
eb setenv JWT_SECRET="your-super-secret-jwt-key-here"

# Set Node environment
eb setenv NODE_ENV="production"
```

**OR** use AWS Console:
1. Go to AWS Elastic Beanstalk Console
2. Select your environment
3. Configuration → Software → Environment properties
4. Add: `DATABASE_URL`, `JWT_SECRET`, `NODE_ENV`

---

## 📱 Step 6: Update Flutter App with AWS URL

After deployment, you'll get a URL like:
`https://hazardnet-production.us-east-1.elasticbeanstalk.com`

Update `lib/core/config/api_config.dart`:

```dart
static const String awsBackendUrl = 'https://hazardnet-production.us-east-1.elasticbeanstalk.com/api';
```

---

## ✅ Step 7: Test Your AWS Backend

### Test health endpoint:
```bash
curl https://your-aws-url.elasticbeanstalk.com/health
```

Should return:
```json
{"status":"ok","timestamp":"...","uptime":123}
```

---

## 🔄 Step 8: Deploy Updates

Whenever you update backend code:

```bash
cd backend
git add .
git commit -m "Update backend"
eb deploy
```

---

## 💰 AWS Free Tier Limits

Your free tier includes:
- ✅ 750 hours/month of t2.micro EC2 instance (enough for 24/7)
- ✅ 5GB storage
- ✅ 15GB data transfer out
- ⚠️ Free for 12 months from signup

**Cost after free tier:** ~$15-20/month for t2.micro

---

## 🎯 How Dual Backend Works

### When Laptop is ON:
```
📱 Phone → Checks Laptop (192.168.31.39:3000)
         → ✅ Connected!
         → Uses Laptop Backend
```

### When Laptop is OFF:
```
📱 Phone → Checks Laptop (192.168.31.39:3000)
         → ❌ Timeout (3 seconds)
         → Checks AWS (your-aws-url.com)
         → ✅ Connected!
         → Uses AWS Backend
```

**Seamless automatic switching!** 🎉

---

## 📊 Monitoring Your AWS Backend

### View logs:
```bash
eb logs
```

### Check status:
```bash
eb status
```

### Open in browser:
```bash
eb open
```

### SSH into server:
```bash
eb ssh
```

---

## 🛑 Stop/Terminate (To Save Credits)

### Temporarily stop:
```bash
eb scale 0  # Stop instances
eb scale 1  # Start again
```

### Permanently delete:
```bash
eb terminate hazardnet-production
```

---

## 🔧 Troubleshooting

### Problem: Deployment fails
```bash
eb logs  # Check error logs
eb ssh   # SSH into server to debug
```

### Problem: Database connection error
- Check environment variables: `eb printenv`
- Verify DATABASE_URL is correct
- Ensure Neon allows connections from AWS IP

### Problem: 502 Bad Gateway
- Backend crashed, check logs: `eb logs`
- Usually missing environment variables

---

## 💡 Alternative AWS Options

### Option 1: AWS Lambda + API Gateway (Serverless)
- **Pros:** Free tier = 1M requests/month
- **Cons:** More complex setup
- **Cost:** Almost free forever

### Option 2: AWS Lightsail
- **Pros:** Fixed pricing ($3.50/month)
- **Cons:** No free tier
- **Best for:** Simple, predictable costs

### Option 3: AWS EC2 + RDS
- **Pros:** Full control
- **Cons:** More expensive, complex
- **Best for:** Large scale production

---

## 🎉 Benefits of Dual Backend

✅ **Development:** Use laptop backend (fast, free)
✅ **Testing:** Friends can test without your laptop on
✅ **Production:** App works 24/7 via AWS
✅ **Backup:** If one fails, other takes over
✅ **Cost:** Only pay when you need 24/7 availability

---

## 📞 Quick Commands Reference

```bash
# Deploy
eb init
eb create
eb deploy

# Monitor
eb status
eb logs
eb health

# Manage
eb scale 1
eb terminate

# Environment
eb setenv KEY=value
eb printenv
```

---

## 🚀 Ready to Deploy?

Run these commands in order:

```bash
cd backend
eb init -p node.js-18 hazardnet-backend
eb create hazardnet-production --instance-type t2.micro --single
eb setenv DATABASE_URL="your-neon-url-here"
eb setenv JWT_SECRET="your-secret-here"
eb open
```

Then update Flutter app with your AWS URL and rebuild APK!

---

**Your app will automatically choose the best backend!** 🎯
