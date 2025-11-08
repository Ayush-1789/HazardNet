# 🗄️ Neon PostgreSQL Database Setup for HazardNet

## 📋 Overview
This guide will help you set up a **Neon PostgreSQL** database for the HazardNet application. Neon is a serverless PostgreSQL platform perfect for modern applications.

---

## 🚀 Step 1: Create Neon Account

1. **Visit Neon.tech**
   - Go to: https://neon.tech
   - Click **"Sign Up"** or **"Get Started"**

2. **Sign Up Options:**
   - ✅ GitHub (Recommended - fastest)
   - ✅ Google
   - ✅ Email

3. **Verify Your Account**
   - Check your email for verification link
   - Click to verify

---

## 🏗️ Step 2: Create Your Project

1. **After login, click "Create Project"**

2. **Configure Your Project:**
   ```
   Project Name: hazardnet-db
   Region: Choose closest to your location
      - US East (Ohio) - us-east-2
      - Europe (Frankfurt) - eu-central-1
      - Asia Pacific (Singapore) - ap-southeast-1
   PostgreSQL Version: 16 (Latest)
   ```

3. **Click "Create Project"**

4. **Save Your Connection Details** (IMPORTANT!)
   ```
   Host: ep-xxxxx-xxxxx.region.aws.neon.tech
   Database: neondb
   Username: your-username
   Password: ********** (SAVE THIS - shown only once!)
   ```

---

## 🔌 Step 3: Get Connection String

After creating the project, you'll see the connection string:

```
postgresql://username:password@ep-xxxxx.region.aws.neon.tech/neondb?sslmode=require
```

**Save this in a secure location!**

---

## 📊 Step 4: Create Database Schema

### Option A: Using Neon SQL Editor (Web Interface)

1. Go to your Neon dashboard
2. Click on **"SQL Editor"** tab
3. Copy and paste the schema from `database/schema.sql`
4. Click **"Run"** to execute

### Option B: Using pgAdmin or DBeaver

1. Download **pgAdmin** (https://www.pgadmin.org/) or **DBeaver** (https://dbeaver.io/)
2. Create a new connection with your Neon credentials
3. Open a new SQL query window
4. Execute the schema from `database/schema.sql`

### Option C: Using Command Line (psql)

```bash
# Install PostgreSQL client if not installed
# Windows: Download from postgresql.org
# Mac: brew install postgresql
# Linux: sudo apt-get install postgresql-client

# Connect to Neon
psql "postgresql://username:password@ep-xxxxx.region.aws.neon.tech/neondb?sslmode=require"

# Then copy-paste schema or use:
\i database/schema.sql
```

---

## 🔑 Step 5: Update Environment Variables

1. **Copy `.env.example` to `.env`:**
   ```bash
   cp .env.example .env
   ```

2. **Edit `.env` and add your Neon credentials:**
   ```env
   # Database Configuration
   DATABASE_URL=postgresql://username:password@ep-xxxxx.region.aws.neon.tech/neondb?sslmode=require
   
   # Individual components (if needed)
   DB_HOST=ep-xxxxx-xxxxx.region.aws.neon.tech
   DB_PORT=5432
   DB_NAME=neondb
   DB_USER=your-username
   DB_PASSWORD=your-password
   DB_SSL_MODE=require
   ```

3. **⚠️ IMPORTANT:** Never commit `.env` to Git!

---

## ✅ Step 6: Test Connection

### Using Node.js (Recommended for Backend)

1. **Install PostgreSQL client:**
   ```bash
   npm install pg
   # or
   yarn add pg
   ```

2. **Test connection:**
   ```javascript
   const { Client } = require('pg');
   
   const client = new Client({
     connectionString: process.env.DATABASE_URL,
     ssl: {
       rejectUnauthorized: false
     }
   });
   
   async function testConnection() {
     try {
       await client.connect();
       const res = await client.query('SELECT NOW()');
       console.log('✅ Connected to Neon PostgreSQL!');
       console.log('Server time:', res.rows[0].now);
       await client.end();
     } catch (err) {
       console.error('❌ Connection error:', err);
     }
   }
   
   testConnection();
   ```

### Using Python (Alternative)

1. **Install PostgreSQL adapter:**
   ```bash
   pip install psycopg2-binary
   ```

2. **Test connection:**
   ```python
   import psycopg2
   import os
   
   try:
       conn = psycopg2.connect(os.getenv('DATABASE_URL'))
       cur = conn.cursor()
       cur.execute('SELECT NOW()')
       print('✅ Connected to Neon PostgreSQL!')
       print('Server time:', cur.fetchone()[0])
       cur.close()
       conn.close()
   except Exception as e:
       print('❌ Connection error:', e)
   ```

---

## 📈 Step 7: Neon Dashboard Features

Once your database is set up, explore these Neon features:

### 1. **SQL Editor**
- Run queries directly in browser
- View table data
- Test your schema

### 2. **Monitoring**
- View connection count
- Monitor query performance
- Check database size

### 3. **Branching** (Advanced)
- Create database branches for testing
- Perfect for development/staging environments
- Branch from production for testing migrations

### 4. **Connection Pooling**
- Neon provides built-in pooling
- Use pooled connection string for better performance:
  ```
  postgresql://username:password@ep-xxxxx-pooler.region.aws.neon.tech/neondb
  ```

---

## 🔒 Security Best Practices

1. **✅ Never commit database credentials to Git**
   - Use `.env` file
   - Add `.env` to `.gitignore` (already done)

2. **✅ Use SSL connections**
   - Always include `?sslmode=require` in connection string

3. **✅ Rotate passwords regularly**
   - Change password every 90 days
   - Update in Neon dashboard

4. **✅ Use connection pooling**
   - Prevents connection exhaustion
   - Better performance

5. **✅ Limit database access**
   - Create separate users for different services
   - Grant minimum required permissions

---

## 🌐 Neon Free Tier Limits

- ✅ **Storage:** 0.5 GB
- ✅ **Compute:** Shared CPU
- ✅ **Branches:** 10 branches
- ✅ **Projects:** 1 project
- ✅ **Always Available:** Auto-suspend after inactivity

**For HazardNet MVP, free tier is sufficient!**

To scale up later:
- **Launch Plan:** $19/month - 10 GB storage
- **Scale Plan:** $69/month - 50 GB storage

---

## 🆘 Troubleshooting

### Error: "Connection timeout"
**Solution:** Check your firewall and internet connection. Neon requires outbound access to port 5432.

### Error: "SSL connection required"
**Solution:** Add `?sslmode=require` to your connection string.

### Error: "Authentication failed"
**Solution:** 
- Double-check username and password
- Password might have special characters - use URL encoding
- Reset password in Neon dashboard if needed

### Error: "Too many connections"
**Solution:** 
- Use connection pooling
- Close connections properly in your code
- Use pooled connection string

---

## 📚 Additional Resources

- **Neon Documentation:** https://neon.tech/docs
- **Neon API Reference:** https://neon.tech/docs/reference/api-reference
- **Neon Discord Community:** https://discord.gg/92vNTzKDGp
- **PostgreSQL Documentation:** https://www.postgresql.org/docs/

---

## 🎯 Next Steps

After setting up Neon:

1. ✅ Execute `database/schema.sql` to create tables
2. ✅ Test connection using `database/test_connection.js`
3. ✅ Seed initial data using `database/seed_data.sql`
4. ✅ Set up backend API to connect to Neon
5. ✅ Update Flutter app to call backend API

---

**Your Neon PostgreSQL database is ready for HazardNet! 🚗💨**
