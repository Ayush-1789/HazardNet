const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');
const pool = require('../db');

// Middleware to check if user is an authority
const checkAuthority = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    
    const result = await pool.query(
      'SELECT * FROM authority_users WHERE user_id = $1 AND is_verified = TRUE',
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(403).json({ error: 'Access denied. Authority verification required.' });
    }

    req.authority = result.rows[0];
    next();

  } catch (error) {
    console.error('Authority check error:', error);
    res.status(500).json({ error: 'Failed to verify authority status' });
  }
};

// ================================================================
// AUTHORITY REGISTRATION AND MANAGEMENT
// ================================================================

// Register as authority (requires admin approval)
router.post('/register', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { authorityType, jurisdiction, badgeNumber, department } = req.body;

    const validTypes = ['police', 'traffic_police', 'municipality', 'road_dept', 'emergency_services'];
    if (!validTypes.includes(authorityType)) {
      return res.status(400).json({ error: 'Invalid authority type' });
    }

    // Check if already registered
    const existing = await pool.query(
      'SELECT * FROM authority_users WHERE user_id = $1',
      [userId]
    );

    if (existing.rows.length > 0) {
      return res.status(400).json({ error: 'Already registered as authority' });
    }

    const result = await pool.query(
      `INSERT INTO authority_users 
       (user_id, authority_type, jurisdiction, badge_number, department)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [userId, authorityType, jurisdiction, badgeNumber, department]
    );

    res.status(201).json({
      message: 'Authority registration submitted. Awaiting verification.',
      authority: result.rows[0]
    });

  } catch (error) {
    console.error('Authority registration error:', error);
    res.status(500).json({ error: 'Failed to register authority' });
  }
});

// Get authority profile
router.get('/profile', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await pool.query(
      `SELECT au.*, u.display_name, u.email, u.phone_number
       FROM authority_users au
       JOIN users u ON au.user_id = u.id
       WHERE au.user_id = $1`,
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Authority profile not found' });
    }

    res.json({ authority: result.rows[0] });

  } catch (error) {
    console.error('Get authority profile error:', error);
    res.status(500).json({ error: 'Failed to retrieve authority profile' });
  }
});

// ================================================================
// HAZARD MANAGEMENT FOR AUTHORITIES
// ================================================================

// Get hazards in jurisdiction
router.get('/hazards', authenticateToken, checkAuthority, async (req, res) => {
  try {
    const { 
      status = 'active', 
      severity, 
      type,
      limit = 100,
      offset = 0
    } = req.query;

    const jurisdiction = req.authority.jurisdiction;

    let whereConditions = ['h.is_active = TRUE'];
    const params = [];
    let paramCount = 0;

    if (severity) {
      paramCount++;
      whereConditions.push(`h.severity = $${paramCount}`);
      params.push(severity);
    }

    if (type) {
      paramCount++;
      whereConditions.push(`h.type = $${paramCount}`);
      params.push(type);
    }

    // Add jurisdiction filter (in a real app, this would use proper geo queries)
    // For now, we'll return all hazards
    // if (jurisdiction) {
    //   whereConditions.push(`h.location LIKE '%${jurisdiction}%'`);
    // }

    paramCount++;
    paramCount++;
    const query = `
      SELECT 
        h.*,
        u.display_name as reported_by_name,
        u.email as reported_by_email,
        COUNT(DISTINCT hv.id) as verification_count,
        (SELECT action_type FROM hazard_authority_actions 
         WHERE hazard_id = h.id 
         ORDER BY action_taken_at DESC LIMIT 1) as last_authority_action
      FROM hazards h
      LEFT JOIN users u ON h.reported_by = u.id
      LEFT JOIN hazard_verifications hv ON h.id = hv.hazard_id
      WHERE ${whereConditions.join(' AND ')}
      GROUP BY h.id, u.display_name, u.email
      ORDER BY h.severity DESC, h.detected_at DESC
      LIMIT $${paramCount - 1} OFFSET $${paramCount}
    `;

    params.push(limit, offset);

    const result = await pool.query(query, params);

    res.json({
      hazards: result.rows,
      total: result.rows.length,
      jurisdiction: jurisdiction
    });

  } catch (error) {
    console.error('Get jurisdiction hazards error:', error);
    res.status(500).json({ error: 'Failed to retrieve hazards' });
  }
});

// Take action on hazard
router.post('/hazards/:hazardId/action', authenticateToken, checkAuthority, async (req, res) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const { hazardId } = req.params;
    const { actionType, notes, estimatedResolutionTime } = req.body;
    const authorityId = req.authority.id;

    const validActions = ['acknowledged', 'investigating', 'in_progress', 'resolved', 'rejected'];
    if (!validActions.includes(actionType)) {
      return res.status(400).json({ error: 'Invalid action type' });
    }

    // Record authority action
    const actionResult = await client.query(
      `INSERT INTO hazard_authority_actions 
       (hazard_id, authority_id, action_type, notes, estimated_resolution_time)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [hazardId, authorityId, actionType, notes, estimatedResolutionTime]
    );

    // Update hazard status based on action
    if (actionType === 'resolved') {
      await client.query(
        `UPDATE hazards 
         SET is_active = FALSE, resolved_at = CURRENT_TIMESTAMP, resolved_by = $1
         WHERE id = $2`,
        [req.user.userId, hazardId]
      );
    }

    // Create alert for hazard reporter
    const hazardInfo = await client.query(
      'SELECT reported_by, type FROM hazards WHERE id = $1',
      [hazardId]
    );

    if (hazardInfo.rows.length > 0 && hazardInfo.rows[0].reported_by) {
      const reporterId = hazardInfo.rows[0].reported_by;
      const hazardType = hazardInfo.rows[0].type;

      await client.query(
        `INSERT INTO alerts 
         (user_id, title, message, type, severity, hazard_id, metadata)
         VALUES ($1, $2, $3, $4, $5, $6, $7)`,
        [
          reporterId,
          'Authority Action on Your Report',
          `Authorities have ${actionType.replace('_', ' ')} your ${hazardType} report. ${notes || ''}`,
          'community',
          'info',
          hazardId,
          JSON.stringify({ authorityAction: actionType, authorityId: authorityId })
        ]
      );
    }

    await client.query('COMMIT');

    res.status(201).json({
      message: 'Action recorded successfully',
      action: actionResult.rows[0]
    });

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Authority action error:', error);
    res.status(500).json({ error: 'Failed to record action' });
  } finally {
    client.release();
  }
});

// Get action history for a hazard
router.get('/hazards/:hazardId/actions', authenticateToken, checkAuthority, async (req, res) => {
  try {
    const { hazardId } = req.params;

    const result = await pool.query(
      `SELECT 
         haa.*,
         au.authority_type,
         au.department,
         u.full_name as authority_name
       FROM hazard_authority_actions haa
       JOIN authority_users au ON haa.authority_id = au.id
       JOIN users u ON au.user_id = u.id
       WHERE haa.hazard_id = $1
       ORDER BY haa.action_taken_at DESC`,
      [hazardId]
    );

    res.json({ actions: result.rows });

  } catch (error) {
    console.error('Get action history error:', error);
    res.status(500).json({ error: 'Failed to retrieve action history' });
  }
});

// ================================================================
// AUTHORITY DASHBOARD STATISTICS
// ================================================================

// Get dashboard statistics
router.get('/dashboard/stats', authenticateToken, checkAuthority, async (req, res) => {
  try {
    const authorityId = req.authority.id;

    // Get various statistics
    const stats = await pool.query(`
      SELECT 
        (SELECT COUNT(*) FROM hazards WHERE is_active = TRUE) as total_active_hazards,
        (SELECT COUNT(*) FROM hazards WHERE is_active = TRUE AND severity = 'critical') as critical_hazards,
        (SELECT COUNT(*) FROM hazard_authority_actions WHERE authority_id = $1) as total_actions_taken,
        (SELECT COUNT(*) FROM hazards WHERE resolved_by = $2) as hazards_resolved,
        (SELECT COUNT(*) FROM sos_alerts WHERE status = 'active') as active_sos_alerts
    `, [authorityId, req.user.userId]);

    // Get hazards by type
    const hazardsByType = await pool.query(`
      SELECT type, COUNT(*) as count
      FROM hazards
      WHERE is_active = TRUE
      GROUP BY type
      ORDER BY count DESC
    `);

    // Get recent actions
    const recentActions = await pool.query(`
      SELECT 
        haa.*,
        h.type as hazard_type,
        h.severity as hazard_severity
      FROM hazard_authority_actions haa
      JOIN hazards h ON haa.hazard_id = h.id
      WHERE haa.authority_id = $1
      ORDER BY haa.action_taken_at DESC
      LIMIT 10
    `, [authorityId]);

    res.json({
      statistics: stats.rows[0],
      hazardsByType: hazardsByType.rows,
      recentActions: recentActions.rows
    });

  } catch (error) {
    console.error('Get dashboard stats error:', error);
    res.status(500).json({ error: 'Failed to retrieve dashboard statistics' });
  }
});

// Broadcast official alert to area
router.post('/broadcast-alert', authenticateToken, checkAuthority, async (req, res) => {
  try {
    const { title, message, latitude, longitude, radiusKm, severity } = req.body;

    if (!title || !message || !latitude || !longitude) {
      return res.status(400).json({ error: 'Title, message, and location are required' });
    }

    // Get users in the area
    const usersInArea = await pool.query(
      `SELECT DISTINCT u.id
       FROM users u
       JOIN trip_sessions ts ON u.id = ts.user_id
       WHERE ts.is_active = TRUE
       AND (
         6371 * acos(
           cos(radians($1)) * cos(radians(ts.current_latitude)) *
           cos(radians(ts.current_longitude) - radians($2)) +
           sin(radians($1)) * sin(radians(ts.current_latitude))
         )
       ) <= $3`,
      [latitude, longitude, radiusKm || 10]
    );

    // Create alerts for all users in area
    const alertPromises = usersInArea.rows.map(user => {
      return pool.query(
        `INSERT INTO alerts 
         (user_id, title, message, type, severity, metadata)
         VALUES ($1, $2, $3, $4, $5, $6)`,
        [
          user.id,
          `[OFFICIAL] ${title}`,
          message,
          'system',
          severity || 'warning',
          JSON.stringify({
            authorityBroadcast: true,
            authorityId: req.authority.id,
            authorityType: req.authority.authority_type,
            location: { latitude, longitude },
            radiusKm: radiusKm || 10
          })
        ]
      );
    });

    await Promise.all(alertPromises);

    res.json({
      message: 'Alert broadcast successfully',
      usersNotified: usersInArea.rows.length
    });

  } catch (error) {
    console.error('Broadcast alert error:', error);
    res.status(500).json({ error: 'Failed to broadcast alert' });
  }
});

module.exports = router;
