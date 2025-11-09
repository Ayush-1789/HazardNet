require('dotenv').config();
const { pool } = require('../db');

(async () => {
  try {
    const hashed = "$2b$10$NnXjNc.HsmNDVeZKBZBf5.gZkA.eONoxGSnx5nJKMDrHuXSaS931S";
    const email = 'test.user@hazardnet.com';

    const res = await pool.query(
      `UPDATE users SET password_hash = $1 WHERE email = $2 RETURNING id, email`,
      [hashed, email]
    );

    console.log('Updated rows:', res.rowCount);
    console.log('Result:', res.rows);
  } catch (e) {
    console.error('Error updating password:', e);
  } finally {
    await pool.end();
  }
})();
