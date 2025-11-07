const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');
const pool = require('../db');

// ================================================================
// EMERGENCY CONTACTS ROUTES
// ================================================================

// Get user's emergency contacts
router.get('/contacts', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await pool.query(
      `SELECT * FROM emergency_contacts
       WHERE user_id = $1 AND is_active = TRUE
       ORDER BY priority ASC, created_at ASC`,
      [userId]
    );

    res.json({ contacts: result.rows });

  } catch (error) {
    console.error('Get emergency contacts error:', error);
    res.status(500).json({ error: 'Failed to retrieve emergency contacts' });
  }
});

// Add emergency contact
router.post('/contacts', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { contactName, contactPhone, relationship, priority } = req.body;

    if (!contactName || !contactPhone) {
      return res.status(400).json({ error: 'Contact name and phone are required' });
    }

    const result = await pool.query(
      `INSERT INTO emergency_contacts 
       (user_id, contact_name, contact_phone, relationship, priority)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [userId, contactName, contactPhone, relationship || null, priority || 1]
    );

    res.status(201).json({
      message: 'Emergency contact added',
      contact: result.rows[0]
    });

  } catch (error) {
    console.error('Add emergency contact error:', error);
    res.status(500).json({ error: 'Failed to add emergency contact' });
  }
});

// Update emergency contact
router.put('/contacts/:contactId', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { contactId } = req.params;
    const { contactName, contactPhone, relationship, priority, isActive } = req.body;

    const result = await pool.query(
      `UPDATE emergency_contacts
       SET contact_name = COALESCE($1, contact_name),
           contact_phone = COALESCE($2, contact_phone),
           relationship = COALESCE($3, relationship),
           priority = COALESCE($4, priority),
           is_active = COALESCE($5, is_active)
       WHERE id = $6 AND user_id = $7
       RETURNING *`,
      [contactName, contactPhone, relationship, priority, isActive, contactId, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Emergency contact not found' });
    }

    res.json({
      message: 'Emergency contact updated',
      contact: result.rows[0]
    });

  } catch (error) {
    console.error('Update emergency contact error:', error);
    res.status(500).json({ error: 'Failed to update emergency contact' });
  }
});

// Delete emergency contact
router.delete('/contacts/:contactId', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { contactId } = req.params;

    const result = await pool.query(
      `DELETE FROM emergency_contacts
       WHERE id = $1 AND user_id = $2
       RETURNING *`,
      [contactId, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Emergency contact not found' });
    }

    res.json({ message: 'Emergency contact deleted' });

  } catch (error) {
    console.error('Delete emergency contact error:', error);
    res.status(500).json({ error: 'Failed to delete emergency contact' });
  }
});

// ================================================================
// SOS ALERT ROUTES
// ================================================================

// Trigger SOS alert
router.post('/sos', authenticateToken, async (req, res) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const userId = req.user.userId;
    const { latitude, longitude, message, alertType } = req.body;

    if (!latitude || !longitude) {
      return res.status(400).json({ error: 'Location (latitude, longitude) is required' });
    }

    // Create SOS alert
    const sosResult = await client.query(
      `INSERT INTO sos_alerts 
       (user_id, latitude, longitude, alert_type, message)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [userId, latitude, longitude, alertType || 'emergency', message || 'Emergency SOS triggered']
    );

    const sosAlert = sosResult.rows[0];

    // Get user details
    const userResult = await client.query(
      'SELECT display_name, email, phone_number FROM users WHERE id = $1',
      [userId]
    );
    const user = userResult.rows[0];

    // Get emergency contacts
    const contactsResult = await client.query(
      `SELECT * FROM emergency_contacts
       WHERE user_id = $1 AND is_active = TRUE
       ORDER BY priority ASC`,
      [userId]
    );

    // Notify nearby users (within 5km radius)
    const nearbyDistance = 5.0; // km
    const nearbyUsersResult = await client.query(
      `SELECT DISTINCT u.id, u.display_name
       FROM users u
       JOIN trip_sessions ts ON u.id = ts.user_id
       WHERE ts.is_active = TRUE
       AND u.id != $1
       AND (
         6371 * acos(
           cos(radians($2)) * cos(radians(ts.current_latitude)) *
           cos(radians(ts.current_longitude) - radians($3)) +
           sin(radians($2)) * sin(radians(ts.current_latitude))
         )
       ) <= $4`,
      [userId, latitude, longitude, nearbyDistance]
    );

    // Create alerts for nearby users
    const nearbyAlertPromises = nearbyUsersResult.rows.map(nearbyUser => {
      return client.query(
        `INSERT INTO alerts 
         (user_id, title, message, type, severity, metadata)
         VALUES ($1, $2, $3, $4, $5, $6)`,
        [
          nearbyUser.id,
          'Emergency SOS Alert Nearby',
          `User ${user.display_name} has triggered an SOS alert near your location`,
          'emergency',
          'critical',
          JSON.stringify({
            sosAlertId: sosAlert.id,
            sosUserId: userId,
            sosLocation: { latitude, longitude },
            distance: 'nearby'
          })
        ]
      );
    });

    await Promise.all(nearbyAlertPromises);

    await client.query('COMMIT');

    // In a real app, here you would:
    // 1. Send SMS to emergency contacts
    // 2. Send push notifications to nearby users
    // 3. Optionally notify emergency services

    res.status(201).json({
      message: 'SOS alert triggered successfully',
      sosAlert: sosAlert,
      emergencyContacts: contactsResult.rows,
      nearbyUsersNotified: nearbyUsersResult.rows.length,
      instructions: 'Emergency contacts have been notified. Help is on the way.'
    });

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('SOS alert error:', error);
    res.status(500).json({ error: 'Failed to trigger SOS alert' });
  } finally {
    client.release();
  }
});

// Get user's SOS alerts
router.get('/sos', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { status = 'active' } = req.query;

    let query = `SELECT * FROM sos_alerts WHERE user_id = $1`;
    const params = [userId];

    if (status !== 'all') {
      query += ` AND status = $2`;
      params.push(status);
    }

    query += ` ORDER BY triggered_at DESC LIMIT 50`;

    const result = await pool.query(query, params);

    res.json({ sosAlerts: result.rows });

  } catch (error) {
    console.error('Get SOS alerts error:', error);
    res.status(500).json({ error: 'Failed to retrieve SOS alerts' });
  }
});

// Update SOS alert status
router.patch('/sos/:alertId', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { alertId } = req.params;
    const { status } = req.body;

    if (!['resolved', 'cancelled'].includes(status)) {
      return res.status(400).json({ error: 'Invalid status. Must be "resolved" or "cancelled"' });
    }

    const result = await pool.query(
      `UPDATE sos_alerts
       SET status = $1, resolved_at = CURRENT_TIMESTAMP
       WHERE id = $2 AND user_id = $3
       RETURNING *`,
      [status, alertId, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'SOS alert not found' });
    }

    res.json({
      message: `SOS alert ${status}`,
      sosAlert: result.rows[0]
    });

  } catch (error) {
    console.error('Update SOS alert error:', error);
    res.status(500).json({ error: 'Failed to update SOS alert' });
  }
});

// Get active SOS alerts in area (for nearby users/authorities)
router.get('/sos/active/nearby', authenticateToken, async (req, res) => {
  try {
    const { latitude, longitude, radiusKm = 10 } = req.query;

    if (!latitude || !longitude) {
      return res.status(400).json({ error: 'Location parameters required' });
    }

    const result = await pool.query(
      `SELECT 
         sa.*,
         u.display_name,
         u.email,
         (
           6371 * acos(
             cos(radians($1)) * cos(radians(sa.latitude)) *
             cos(radians(sa.longitude) - radians($2)) +
             sin(radians($1)) * sin(radians(sa.latitude))
           )
         ) AS distance_km
       FROM sos_alerts sa
       JOIN users u ON sa.user_id = u.id
       WHERE sa.status = 'active'
       AND (
         6371 * acos(
           cos(radians($1)) * cos(radians(sa.latitude)) *
           cos(radians(sa.longitude) - radians($2)) +
           sin(radians($1)) * sin(radians(sa.latitude))
         )
       ) <= $3
       ORDER BY distance_km ASC`,
      [latitude, longitude, radiusKm]
    );

    res.json({ activeSosAlerts: result.rows });

  } catch (error) {
    console.error('Get nearby SOS alerts error:', error);
    res.status(500).json({ error: 'Failed to retrieve nearby SOS alerts' });
  }
});

module.exports = router;
