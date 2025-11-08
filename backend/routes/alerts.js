const express = require('express');
const { pool } = require('../db');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Alert severity levels
const ALERT_SEVERITY = {
  INFO: 'info',
  WARNING: 'warning',
  CRITICAL: 'critical',
  EMERGENCY: 'emergency'
};

// Alert types
const ALERT_TYPES = {
  PROXIMITY: 'proximity',           // Nearby hazard detected
  ROAD_CLOSURE: 'road_closure',     // Road closed ahead
  WEATHER: 'weather',               // Weather-related alert
  TRAFFIC: 'traffic',               // Heavy traffic alert
  ACCIDENT: 'accident',             // Accident reported
  EMERGENCY: 'emergency',           // Emergency situation
  SYSTEM: 'system'                  // System notification
};

// Get user's alerts
router.get('/', authenticateToken, async (req, res) => {
  try {
    const { unreadOnly } = req.query;

    let query = `
      SELECT a.*, h.type as hazard_type, h.latitude, h.longitude
      FROM alerts a
      LEFT JOIN hazards h ON a.hazard_id = h.id
      WHERE a.user_id = $1
    `;

    if (unreadOnly === 'true') {
      query += ' AND a.is_read = false';
    }

    query += ' ORDER BY a.timestamp DESC LIMIT 50';

    const result = await pool.query(query, [req.user.userId]);

    const alerts = result.rows.map(a => ({
      id: a.id,
      title: a.title,
      message: a.message,
      type: a.type,
      severity: a.severity,
      isRead: a.is_read,
      hazardId: a.hazard_id,
      hazardType: a.hazard_type,
      timestamp: a.timestamp,
      metadata: a.metadata
    }));

    res.json({ alerts, count: alerts.length });
  } catch (error) {
    console.error('Get alerts error:', error);
    res.status(500).json({ error: 'Failed to get alerts' });
  }
});

// Get unread alerts count
router.get('/unread/count', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT COUNT(*) as count FROM alerts WHERE user_id = $1 AND is_read = false',
      [req.user.userId]
    );

    res.json({ unreadCount: parseInt(result.rows[0].count) });
  } catch (error) {
    console.error('Get unread count error:', error);
    res.status(500).json({ error: 'Failed to get unread count' });
  }
});

// Mark alert as read
router.patch('/:id/read', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      'UPDATE alerts SET is_read = true WHERE id = $1 AND user_id = $2 RETURNING *',
      [req.params.id, req.user.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Alert not found' });
    }

    res.json({ message: 'Alert marked as read' });
  } catch (error) {
    console.error('Mark alert as read error:', error);
    res.status(500).json({ error: 'Failed to mark alert as read' });
  }
});

// Mark all alerts as read
router.patch('/read-all', authenticateToken, async (req, res) => {
  try {
    await pool.query(
      'UPDATE alerts SET is_read = true WHERE user_id = $1 AND is_read = false',
      [req.user.userId]
    );

    res.json({ message: 'All alerts marked as read' });
  } catch (error) {
    console.error('Mark all alerts as read error:', error);
    res.status(500).json({ error: 'Failed to mark all alerts as read' });
  }
});

// Get proximity alerts (hazards near user's location)
router.get('/proximity', authenticateToken, async (req, res) => {
  try {
    const { latitude, longitude, radius = 1 } = req.query; // radius in km

    if (!latitude || !longitude) {
      return res.status(400).json({ error: 'Latitude and longitude are required' });
    }

    const result = await pool.query(
      `SELECT h.*, calculate_distance($1, $2, h.latitude, h.longitude) as distance
       FROM hazards h
       WHERE calculate_distance($1, $2, h.latitude, h.longitude) <= $3
       AND h.severity IN ('High', 'Critical')
       ORDER BY distance ASC`,
      [parseFloat(latitude), parseFloat(longitude), parseFloat(radius)]
    );

    const proximityAlerts = result.rows.map(h => ({
      hazardId: h.id,
      type: h.type,
      severity: h.severity,
      distance: parseFloat(h.distance).toFixed(2),
      latitude: parseFloat(h.latitude),
      longitude: parseFloat(h.longitude),
      message: `${h.severity} ${h.type} detected ${parseFloat(h.distance).toFixed(2)}km ahead`
    }));

    res.json({ alerts: proximityAlerts, count: proximityAlerts.length });
  } catch (error) {
    console.error('Get proximity alerts error:', error);
    res.status(500).json({ error: 'Failed to get proximity alerts' });
  }
});

// CREATE ADVANCED ALERT - Send alert to users in specific area
router.post('/broadcast', authenticateToken, async (req, res) => {
  try {
    const { 
      title, 
      message, 
      type, 
      severity, 
      latitude, 
      longitude, 
      radius = 5, // km
      hazardId,
      metadata 
    } = req.body;

    if (!title || !message || !type || !latitude || !longitude) {
      return res.status(400).json({ 
        error: 'Title, message, type, latitude, and longitude are required' 
      });
    }

    // Find all users within the radius during active trips
    const usersInArea = await pool.query(
      `SELECT DISTINCT user_id 
       FROM trip_sessions 
       WHERE end_time IS NULL 
       AND calculate_distance($1, $2, start_latitude, start_longitude) <= $3`,
      [parseFloat(latitude), parseFloat(longitude), parseFloat(radius)]
    );

    // Create alerts for all users in the area
    const alertPromises = usersInArea.rows.map(user => 
      pool.query(
        `INSERT INTO alerts 
         (user_id, title, message, type, severity, hazard_id, metadata) 
         VALUES ($1, $2, $3, $4, $5, $6, $7)
         RETURNING *`,
        [user.user_id, title, message, type, severity || 'warning', hazardId, metadata]
      )
    );

    await Promise.all(alertPromises);

    res.json({ 
      message: 'Broadcast alert sent',
      recipientCount: usersInArea.rows.length,
      area: { latitude, longitude, radius }
    });
  } catch (error) {
    console.error('Broadcast alert error:', error);
    res.status(500).json({ error: 'Failed to broadcast alert' });
  }
});

// EMERGENCY ALERT - Send critical alert to all active users
router.post('/emergency', authenticateToken, async (req, res) => {
  try {
    const { title, message, location, metadata } = req.body;

    if (!title || !message) {
      return res.status(400).json({ error: 'Title and message are required' });
    }

    // Get all users with active trips
    const activeUsers = await pool.query(
      'SELECT DISTINCT user_id FROM trip_sessions WHERE end_time IS NULL'
    );

    // Create emergency alerts for all active users
    const alertPromises = activeUsers.rows.map(user =>
      pool.query(
        `INSERT INTO alerts 
         (user_id, title, message, type, severity, metadata) 
         VALUES ($1, $2, $3, $4, $5, $6)`,
        [user.user_id, title, message, ALERT_TYPES.EMERGENCY, ALERT_SEVERITY.EMERGENCY, metadata]
      )
    );

    await Promise.all(alertPromises);

    res.json({
      message: 'Emergency alert sent to all active users',
      recipientCount: activeUsers.rows.length
    });
  } catch (error) {
    console.error('Emergency alert error:', error);
    res.status(500).json({ error: 'Failed to send emergency alert' });
  }
});

// ROUTE ALERT - Get alerts along a specific route
router.post('/route', authenticateToken, async (req, res) => {
  try {
    const { waypoints, buffer = 0.5 } = req.body; // buffer in km

    if (!waypoints || !Array.isArray(waypoints) || waypoints.length < 2) {
      return res.status(400).json({ 
        error: 'At least 2 waypoints are required' 
      });
    }

    // Find hazards near the route
    const hazardsAlongRoute = [];
    
    for (let i = 0; i < waypoints.length - 1; i++) {
      const start = waypoints[i];
      const end = waypoints[i + 1];
      
      // Check for hazards between waypoints
      const result = await pool.query(
        `SELECT h.*, 
                calculate_distance($1, $2, h.latitude, h.longitude) as distance_from_start,
                calculate_distance($3, $4, h.latitude, h.longitude) as distance_from_end
         FROM hazards h
         WHERE (calculate_distance($1, $2, h.latitude, h.longitude) <= $5
                OR calculate_distance($3, $4, h.latitude, h.longitude) <= $5)
         AND h.status = 'active'
         ORDER BY distance_from_start ASC`,
        [start.latitude, start.longitude, end.latitude, end.longitude, buffer]
      );
      
      hazardsAlongRoute.push(...result.rows);
    }

    // Remove duplicates
    const uniqueHazards = Array.from(
      new Map(hazardsAlongRoute.map(h => [h.id, h])).values()
    );

    res.json({
      hazards: uniqueHazards,
      count: uniqueHazards.length,
      route: { waypoints, buffer }
    });
  } catch (error) {
    console.error('Route alert error:', error);
    res.status(500).json({ error: 'Failed to get route alerts' });
  }
});

// WEATHER ALERT - Send weather-related alert
router.post('/weather', authenticateToken, async (req, res) => {
  try {
    const { title, message, severity, affectedArea, metadata } = req.body;

    if (!title || !message || !affectedArea) {
      return res.status(400).json({ 
        error: 'Title, message, and affected area are required' 
      });
    }

    const { latitude, longitude, radius } = affectedArea;

    // Find users in affected area
    const usersInArea = await pool.query(
      `SELECT DISTINCT user_id 
       FROM trip_sessions 
       WHERE end_time IS NULL 
       AND calculate_distance($1, $2, start_latitude, start_longitude) <= $3`,
      [parseFloat(latitude), parseFloat(longitude), parseFloat(radius)]
    );

    // Send weather alerts
    const alertPromises = usersInArea.rows.map(user =>
      pool.query(
        `INSERT INTO alerts 
         (user_id, title, message, type, severity, metadata) 
         VALUES ($1, $2, $3, $4, $5, $6)`,
        [user.user_id, title, message, ALERT_TYPES.WEATHER, severity || 'warning', metadata]
      )
    );

    await Promise.all(alertPromises);

    res.json({
      message: 'Weather alert sent',
      recipientCount: usersInArea.rows.length,
      affectedArea
    });
  } catch (error) {
    console.error('Weather alert error:', error);
    res.status(500).json({ error: 'Failed to send weather alert' });
  }
});

// TRAFFIC ALERT - Send traffic congestion alert
router.post('/traffic', authenticateToken, async (req, res) => {
  try {
    const { title, message, location, severity, estimatedDelay, metadata } = req.body;

    if (!title || !message || !location) {
      return res.status(400).json({ 
        error: 'Title, message, and location are required' 
      });
    }

    const { latitude, longitude, radius = 2 } = location;

    // Find users approaching the area
    const usersNearby = await pool.query(
      `SELECT DISTINCT user_id 
       FROM trip_sessions 
       WHERE end_time IS NULL 
       AND calculate_distance($1, $2, start_latitude, start_longitude) <= $3`,
      [parseFloat(latitude), parseFloat(longitude), parseFloat(radius)]
    );

    // Send traffic alerts
    const alertPromises = usersNearby.rows.map(user =>
      pool.query(
        `INSERT INTO alerts 
         (user_id, title, message, type, severity, metadata) 
         VALUES ($1, $2, $3, $4, $5, $6)`,
        [
          user.user_id, 
          title, 
          message, 
          ALERT_TYPES.TRAFFIC, 
          severity || 'info',
          { ...metadata, estimatedDelay }
        ]
      )
    );

    await Promise.all(alertPromises);

    res.json({
      message: 'Traffic alert sent',
      recipientCount: usersNearby.rows.length,
      location,
      estimatedDelay
    });
  } catch (error) {
    console.error('Traffic alert error:', error);
    res.status(500).json({ error: 'Failed to send traffic alert' });
  }
});

// Get alert statistics
router.get('/stats', authenticateToken, async (req, res) => {
  try {
    const stats = await pool.query(
      `SELECT 
        COUNT(*) as total_alerts,
        COUNT(*) FILTER (WHERE is_read = false) as unread_alerts,
        COUNT(*) FILTER (WHERE severity = 'critical') as critical_alerts,
        COUNT(*) FILTER (WHERE severity = 'emergency') as emergency_alerts,
        COUNT(*) FILTER (WHERE type = 'proximity') as proximity_alerts,
        COUNT(*) FILTER (WHERE timestamp >= NOW() - INTERVAL '24 hours') as alerts_24h
       FROM alerts
       WHERE user_id = $1`,
      [req.user.userId]
    );

    res.json(stats.rows[0]);
  } catch (error) {
    console.error('Get alert stats error:', error);
    res.status(500).json({ error: 'Failed to get alert statistics' });
  }
});

// Delete old alerts (older than 30 days)
router.delete('/cleanup', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      `DELETE FROM alerts 
       WHERE user_id = $1 
       AND timestamp < NOW() - INTERVAL '30 days'
       AND is_read = true`,
      [req.user.userId]
    );

    res.json({ 
      message: 'Old alerts cleaned up',
      deletedCount: result.rowCount 
    });
  } catch (error) {
    console.error('Cleanup alerts error:', error);
    res.status(500).json({ error: 'Failed to cleanup alerts' });
  }
});

module.exports = router;
