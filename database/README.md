# HazardNet Database Setup Guide

## 🗄️ Neon PostgreSQL Database Configuration

This directory contains all database setup files for the HazardNet road safety application using Neon serverless PostgreSQL.

---

## 📁 File Structure

```
database/
├── README.md               # This file - comprehensive setup guide
├── neon_setup.md          # Neon account and project setup instructions
├── schema.sql             # Complete database schema with tables, indexes, functions
├── seed_data.sql          # Sample test data for development
└── test_connection.js     # Node.js script to verify database connection
```

---

## 🚀 Quick Start

### 1️⃣ Create Neon Account and Project

Follow the detailed instructions in **`neon_setup.md`** to:
- Create a free Neon account
- Set up a new project
- Get your connection string
- Configure security settings

### 2️⃣ Set Up Environment Variables

Create a `.env` file in the project root:

```bash
# Neon PostgreSQL Connection String
DATABASE_URL=postgresql://[username]:[password]@[host]/[database]?sslmode=require

# Example:
# DATABASE_URL=postgresql://hazardnet_user:your_password@ep-cool-shadow-123456.us-east-2.aws.neon.tech/hazardnet?sslmode=require
```

**⚠️ Important:** Add `.env` to your `.gitignore` to keep credentials secure!

### 3️⃣ Install Dependencies

```bash
npm install pg dotenv
```

### 4️⃣ Create Database Schema

Run the schema SQL file using Neon SQL Editor or psql:

**Option A: Neon Web Console**
1. Go to your Neon project dashboard
2. Click **SQL Editor**
3. Copy content from `schema.sql`
4. Click **Run**

**Option B: Command Line (psql)**
```bash
psql $DATABASE_URL -f database/schema.sql
```

**Option C: Node.js Script**
```bash
node -e "require('dotenv').config(); const fs = require('fs'); const { Client } = require('pg'); const client = new Client({ connectionString: process.env.DATABASE_URL, ssl: { rejectUnauthorized: false } }); client.connect().then(() => client.query(fs.readFileSync('database/schema.sql', 'utf8'))).then(() => { console.log('✅ Schema created!'); client.end(); }).catch(err => console.error('❌ Error:', err));"
```

### 5️⃣ Load Seed Data (Optional for Testing)

```bash
psql $DATABASE_URL -f database/seed_data.sql
```

Or use Node.js:
```bash
node -e "require('dotenv').config(); const fs = require('fs'); const { Client } = require('pg'); const client = new Client({ connectionString: process.env.DATABASE_URL, ssl: { rejectUnauthorized: false } }); client.connect().then(() => client.query(fs.readFileSync('database/seed_data.sql', 'utf8'))).then(() => { console.log('✅ Seed data loaded!'); client.end(); }).catch(err => console.error('❌ Error:', err));"
```

### 6️⃣ Test Connection

```bash
node database/test_connection.js
```

Expected output:
```
============================================================
  🚗 HAZARDNET DATABASE CONNECTION TEST 🚗
============================================================

🔌 Testing database connection...
✅ Successfully connected to Neon PostgreSQL!

📊 Verifying database schema...
✅ Found 8 tables:
   - users
   - hazards
   - hazard_verifications
   - alerts
   - trip_sessions
   - sensor_data
   - maintenance_logs
   - api_keys

🌱 Checking for seed data...
✅ Users: 5 records
✅ Hazards: 10 records
✅ Alerts: 5 records

🎉 All tests completed successfully!
```

---

## 📊 Database Schema Overview

### Core Tables

#### 1. **users**
Stores user profiles, authentication, and damage tracking.
- **Key Fields:** `id`, `email`, `display_name`, `cumulative_damage_score`
- **Purpose:** User authentication and profile management
- **JSON Fields:** `driver_profile`, `preferences`

#### 2. **hazards**
Main table for detected road hazards.
- **Key Fields:** `id`, `type`, `latitude`, `longitude`, `severity`, `confidence`
- **Hazard Types:** pothole, speed_breaker, water_logging, debris, etc.
- **Purpose:** Store ML-detected and user-reported hazards
- **Spatial Indexing:** Optimized for location-based queries

#### 3. **hazard_verifications**
Multi-signature verification system.
- **Purpose:** Track community verification of hazards
- **Auto-verification:** Hazards auto-verify after 3+ confirmations
- **Trigger:** Auto-increments `verification_count` in hazards table

#### 4. **alerts**
User notifications and proximity alerts.
- **Types:** `hazard_proximity`, `maintenance_due`, `achievement`, `safety_tip`
- **Purpose:** Real-time hazard warnings and notifications

#### 5. **trip_sessions**
Driving session analytics.
- **Purpose:** Track user trips, distance, and damage accumulation
- **Analytics:** Speed, duration, hazards encountered

#### 6. **sensor_data**
Raw accelerometer/gyroscope data from phones.
- **Purpose:** Impact detection and ML training data
- **Note:** Can be migrated to time-series DB (TimescaleDB) for production

#### 7. **maintenance_logs**
Vehicle maintenance tracking.
- **Purpose:** Link damage scores to actual repairs
- **Reset:** Resets `cumulative_damage_score` after maintenance

#### 8. **api_keys**
For B2B/Fleet management integrations (future).

---

## 🔧 Database Functions

### `calculate_distance(lat1, lon1, lat2, lon2)`
Calculate distance between two GPS coordinates using Haversine formula.

```sql
SELECT calculate_distance(28.6139, 77.2090, 19.0760, 72.8777) AS distance_km;
-- Returns: ~1148.23 km (Delhi to Mumbai)
```

### Auto-update Triggers
- `update_hazard_verification_count()` - Auto-increments verification count
- `update_updated_at_column()` - Auto-updates `updated_at` timestamps

---

## 📈 Sample Queries

### Get Nearby Hazards (500m radius)
```sql
SELECT 
    id,
    type,
    severity,
    latitude,
    longitude,
    calculate_distance(28.6139, 77.2090, latitude, longitude) AS distance_km
FROM hazards
WHERE is_active = TRUE
  AND calculate_distance(28.6139, 77.2090, latitude, longitude) <= 0.5
ORDER BY distance_km ASC;
```

### User Leaderboard (Top Contributors)
```sql
SELECT 
    display_name,
    total_hazards_reported,
    verified_reports,
    cumulative_damage_score
FROM users
ORDER BY total_hazards_reported DESC
LIMIT 10;
```

### Critical Unverified Hazards
```sql
SELECT 
    type,
    severity,
    latitude,
    longitude,
    reported_by_name,
    detected_at
FROM hazards
WHERE is_verified = FALSE
  AND severity IN ('high', 'critical')
ORDER BY detected_at DESC;
```

### User's Unread Alerts
```sql
SELECT 
    title,
    message,
    type,
    severity,
    timestamp
FROM alerts
WHERE user_id = '11111111-1111-1111-1111-111111111111'
  AND is_read = FALSE
ORDER BY timestamp DESC;
```

---

## 🔐 Security Best Practices

### 1. Environment Variables
Never commit `.env` files to Git!

```bash
# .gitignore
.env
.env.local
.env.production
```

### 2. Connection Pooling (Production)
Use `pg.Pool` instead of `Client` for better performance:

```javascript
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
  max: 20, // Maximum pool size
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Usage
const result = await pool.query('SELECT * FROM users WHERE id = $1', [userId]);
```

### 3. Parameterized Queries (Prevent SQL Injection)
❌ **Bad:**
```javascript
const query = `SELECT * FROM users WHERE email = '${userEmail}'`; // SQL Injection risk!
```

✅ **Good:**
```javascript
const query = 'SELECT * FROM users WHERE email = $1';
const values = [userEmail];
const result = await client.query(query, values);
```

### 4. Role-Based Access Control
Create separate database users for different services:

```sql
-- Read-only user for analytics
CREATE ROLE analytics_user WITH LOGIN PASSWORD 'secure_password';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO analytics_user;

-- App user with limited permissions
CREATE ROLE app_user WITH LOGIN PASSWORD 'secure_password';
GRANT SELECT, INSERT, UPDATE ON users, hazards, alerts TO app_user;
GRANT SELECT ON hazard_verifications TO app_user;
```

---

## 🚀 Deployment Checklist

### Development Environment ✅
- [x] Create Neon project
- [x] Run `schema.sql`
- [x] Load `seed_data.sql` for testing
- [x] Test connection with `test_connection.js`

### Production Environment 🚢
- [ ] Create separate Neon project for production
- [ ] Run `schema.sql` (skip `seed_data.sql`)
- [ ] Set up connection pooling
- [ ] Configure backup strategy (Neon auto-backups)
- [ ] Set up monitoring and alerts
- [ ] Enable Point-in-Time Recovery (PITR)
- [ ] Implement database migration system (e.g., Flyway, Liquibase)

---

## 🔄 Database Migrations (Future)

For production, use a migration tool to track schema changes:

### Option 1: node-pg-migrate
```bash
npm install node-pg-migrate
npx node-pg-migrate create initial-schema
```

### Option 2: Knex.js
```bash
npm install knex pg
npx knex migrate:make create_users_table
```

### Option 3: Prisma
```bash
npm install prisma @prisma/client
npx prisma init
npx prisma migrate dev
```

---

## 📚 Additional Resources

- **Neon Documentation:** https://neon.tech/docs
- **PostgreSQL Docs:** https://www.postgresql.org/docs/
- **node-postgres (pg):** https://node-postgres.com/
- **PostGIS (Geospatial):** https://postgis.net/

---

## 🐛 Troubleshooting

### Issue: "Connection timeout"
**Solution:** Check Neon project is running (not paused). Free tier pauses after inactivity.

### Issue: "SSL required"
**Solution:** Ensure `sslmode=require` in connection string and `ssl: { rejectUnauthorized: false }` in code.

### Issue: "Table does not exist"
**Solution:** Run `schema.sql` first before seed data or tests.

### Issue: "Permission denied for table"
**Solution:** Check database user has correct permissions (see Security section).

### Issue: "Too many connections"
**Solution:** Use connection pooling or reduce max connections in Neon settings.

---

## 📞 Support

For HazardNet-specific issues:
- GitHub: https://github.com/Ayush-1789/HazardNet
- Issues: https://github.com/Ayush-1789/HazardNet/issues

For Neon support:
- Discord: https://discord.gg/neon
- Support: https://neon.tech/support

---

## 📝 License

This database schema is part of the HazardNet project.

---

**Last Updated:** January 2025  
**Schema Version:** 1.0.0  
**Compatible with:** Neon PostgreSQL, PostgreSQL 14+

