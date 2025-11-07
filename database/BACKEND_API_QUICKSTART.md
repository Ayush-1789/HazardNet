# 🚀 HazardNet Backend API - Quick Start Template

## What You Need to Build Next

Your Flutter app is ready to connect to a backend! I've created all the API service files. Now you need to create the backend server.

---

## Option 1: Node.js + Express (Recommended)

### 1. Create Backend Folder

```bash
# Create backend directory (outside Flutter project or in a separate repo)
mkdir hazardnet-backend
cd hazardnet-backend
```

### 2. Initialize Node.js Project

```bash
npm init -y
```

### 3. Install Dependencies

```bash
npm install express pg cors dotenv jsonwebtoken bcrypt
npm install --save-dev nodemon
```

### 4. Create `.env` File

```bash
# Copy from database/.env.example
DATABASE_URL=postgresql://user:password@ep-xxx.neon.tech/hazardnet?sslmode=require
JWT_SECRET=your-super-secret-jwt-key-minimum-32-characters
PORT=3000
NODE_ENV=development
```

### 5. Create `server.js`

```javascript
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Database connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

// Test database connection
pool.query('SELECT NOW()', (err, res) => {
  if (err) {
    console.error('❌ Database connection failed:', err);
  } else {
    console.log('✅ Database connected successfully!');
  }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'ok',
    timestamp: new Date().toISOString(),
    database: 'connected'
  });
});

// Import routes (we'll create these next)
const authRoutes = require('./routes/auth');
const hazardRoutes = require('./routes/hazards');
const alertRoutes = require('./routes/alerts');

app.use('/api/auth', authRoutes);
app.use('/api/hazards', hazardRoutes);
app.use('/api/alerts', alertRoutes);

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ 
    error: 'Something went wrong!',
    message: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
```

### 6. Create Routes Folder Structure

```bash
mkdir routes middleware utils
```

### 7. Create `routes/auth.js`

```javascript
const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

// Register new user
router.post('/register', async (req, res) => {
  try {
    const { email, password, display_name, phone_number, vehicle_type } = req.body;

    // Check if user exists
    const existingUser = await pool.query(
      'SELECT id FROM users WHERE email = $1',
      [email]
    );

    if (existingUser.rows.length > 0) {
      return res.status(400).json({ error: 'User already exists' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert user
    const result = await pool.query(
      `INSERT INTO users (email, password_hash, display_name, phone_number, vehicle_type)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id, email, display_name, phone_number, vehicle_type, created_at`,
      [email, hashedPassword, display_name, phone_number, vehicle_type || 'car']
    );

    const user = result.rows[0];

    // Generate JWT token
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.status(201).json({
      token,
      user: {
        id: user.id,
        email: user.email,
        displayName: user.display_name,
        phoneNumber: user.phone_number,
        vehicleType: user.vehicle_type,
        createdAt: user.created_at
      }
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ error: 'Registration failed' });
  }
});

// Login user
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Get user
    const result = await pool.query(
      'SELECT * FROM users WHERE email = $1',
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const user = result.rows[0];

    // Verify password
    const validPassword = await bcrypt.compare(password, user.password_hash);

    if (!validPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Generate token
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    // Update last login
    await pool.query(
      'UPDATE users SET last_login = NOW() WHERE id = $1',
      [user.id]
    );

    res.json({
      token,
      user: {
        id: user.id,
        email: user.email,
        displayName: user.display_name,
        phoneNumber: user.phone_number,
        vehicleType: user.vehicle_type,
        cumulativeDamageScore: user.cumulative_damage_score,
        isPremium: user.is_premium,
        totalHazardsReported: user.total_hazards_reported
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Login failed' });
  }
});

module.exports = router;
```

### 8. Create `middleware/auth.js`

```javascript
const jwt = require('jsonwebtoken');

function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    return res.status(401).json({ error: 'Authentication required' });
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid or expired token' });
    }
    
    req.user = user;
    next();
  });
}

module.exports = { authenticateToken };
```

### 9. Create `routes/hazards.js`

```javascript
const express = require('express');
const router = express.Router();
const { Pool } = require('pg');
const { authenticateToken } = require('../middleware/auth');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

// Report new hazard (protected)
router.post('/report', authenticateToken, async (req, res) => {
  try {
    const {
      type, latitude, longitude, severity, confidence,
      description, image_url, depth, lane, metadata
    } = req.body;

    const userId = req.user.userId;

    const result = await pool.query(
      `INSERT INTO hazards (
        type, latitude, longitude, severity, confidence,
        description, image_url, depth, lane, metadata, reported_by
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
      RETURNING *`,
      [type, latitude, longitude, severity, confidence, 
       description, image_url, depth, lane, 
       metadata ? JSON.stringify(metadata) : null, userId]
    );

    // Update user's hazard count
    await pool.query(
      'UPDATE users SET total_hazards_reported = total_hazards_reported + 1 WHERE id = $1',
      [userId]
    );

    res.status(201).json({ hazard: result.rows[0] });
  } catch (error) {
    console.error('Report hazard error:', error);
    res.status(500).json({ error: 'Failed to report hazard' });
  }
});

// Get nearby hazards
router.get('/nearby', async (req, res) => {
  try {
    const { latitude, longitude, radius } = req.query;

    const result = await pool.query(
      `SELECT * FROM hazards
       WHERE is_active = TRUE
       AND calculate_distance($1, $2, latitude, longitude) <= $3
       ORDER BY detected_at DESC`,
      [latitude, longitude, radius || 0.5]
    );

    res.json({ hazards: result.rows });
  } catch (error) {
    console.error('Get nearby hazards error:', error);
    res.status(500).json({ error: 'Failed to fetch hazards' });
  }
});

// Verify hazard (protected)
router.post('/:id/verify', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { notes } = req.body;
    const userId = req.user.userId;

    // Insert verification
    await pool.query(
      'INSERT INTO hazard_verifications (hazard_id, user_id, notes) VALUES ($1, $2, $3)',
      [id, userId, notes]
    );

    // Get updated hazard
    const result = await pool.query('SELECT * FROM hazards WHERE id = $1', [id]);

    res.json({ hazard: result.rows[0] });
  } catch (error) {
    console.error('Verify hazard error:', error);
    res.status(500).json({ error: 'Failed to verify hazard' });
  }
});

module.exports = router;
```

### 10. Update `package.json`

```json
{
  "name": "hazardnet-backend",
  "version": "1.0.0",
  "description": "HazardNet Backend API",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "pg": "^8.11.3",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "jsonwebtoken": "^9.0.2",
    "bcrypt": "^5.1.1"
  },
  "devDependencies": {
    "nodemon": "^3.0.2"
  }
}
```

### 11. Start the Server

```bash
npm run dev
```

### 12. Test the API

```bash
# Health check
curl http://localhost:3000/api/health

# Register user
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@hazardnet.com",
    "password": "password123",
    "display_name": "Test User",
    "vehicle_type": "car"
  }'

# Get nearby hazards
curl http://localhost:3000/api/hazards/nearby?latitude=28.6139&longitude=77.2090&radius=0.5
```

---

## Option 2: Python + FastAPI

If you prefer Python:

```bash
mkdir hazardnet-backend
cd hazardnet-backend
python -m venv venv
source venv/bin/activate  # or `venv\Scripts\activate` on Windows
pip install fastapi uvicorn psycopg2-binary python-jose[cryptography] passlib[bcrypt] python-dotenv
```

Create `main.py`:

```python
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import psycopg2
from psycopg2.extras import RealDictCursor
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI()

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Database connection
def get_db():
    return psycopg2.connect(os.getenv('DATABASE_URL'), cursor_factory=RealDictCursor)

@app.get("/api/health")
def health_check():
    return {"status": "ok", "database": "connected"}

# Run with: uvicorn main:app --reload
```

---

## 🎯 Quick Testing Steps

1. **Start backend:** `npm run dev`
2. **Update Flutter .env:** `API_BASE_URL=http://localhost:3000/api`
3. **Test registration in Flutter app**
4. **Test hazard reporting**

---

## 🚀 Deployment Options

### Vercel (Node.js)
```bash
npm install -g vercel
vercel
```

### Railway (Any language)
```bash
# Push to GitHub, connect Railway
# Auto-deploys on push
```

### Render (Any language)
- Create account at render.com
- Connect GitHub repo
- Auto-deploy

---

**Next: Copy this template to create your backend!**

