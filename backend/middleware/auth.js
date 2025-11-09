const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { pool } = require('../db');

/**
 * Authentication middleware.
 *
 * If process.env.DISABLE_AUTH is set to 'true', this middleware will short-circuit
 * and populate req.user with a development user object. It will try to reuse an
 * existing dev user (email: dev@local) or create one if none exists. This ensures
 * req.user.userId is a valid UUID matching the users table to avoid type errors.
 */
const authenticateToken = async (req, res, next) => {
  try {
    // Dev bypass: set DISABLE_AUTH=true in .env to skip auth checks (DEV ONLY)
    if (process.env.DISABLE_AUTH === 'true') {
      // Try to find an existing dev user
      const { rows } = await pool.query('SELECT id, email FROM users WHERE email = $1 LIMIT 1', ['dev@local']);
      if (rows.length > 0) {
        req.user = { userId: rows[0].id, email: rows[0].email };
        return next();
      }

      // Create a lightweight dev user using UPSERT to avoid race conditions
      const hashed = await bcrypt.hash('devpassword', 10);
      const insert = await pool.query(
        `INSERT INTO users (email, password_hash, display_name, phone_number)
         VALUES ($1, $2, $3, $4)
         ON CONFLICT (email) DO UPDATE SET email = EXCLUDED.email
         RETURNING id, email`,
        ['dev@local', hashed, 'Dev User', '0000000000']
      );

      // If insert returned nothing (shouldn't happen with the DO UPDATE), fall back to select
      let devUser = insert.rows[0];
      if (!devUser) {
        const sel = await pool.query('SELECT id, email FROM users WHERE email = $1 LIMIT 1', ['dev@local']);
        devUser = sel.rows[0];
      }

      req.user = { userId: devUser.id, email: devUser.email };
      return next();
    }

    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
      return res.status(401).json({ error: 'Access token required' });
    }

    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
      if (err) {
        return res.status(403).json({ error: 'Invalid or expired token' });
      }
      req.user = user;
      next();
    });
  } catch (error) {
    console.error('Auth middleware error:', error);
    return res.status(500).json({ error: 'Authentication middleware failed' });
  }
};

module.exports = { authenticateToken };
