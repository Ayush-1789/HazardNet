const express = require('express');
const { pool } = require('../db');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Report a new hazard
router.post('/report', authenticateToken, async (req, res) => {
  try {
    const { type, latitude, longitude, severity, confidence, imageUrl, description } = req.body;

    if (!type || !latitude || !longitude || !severity) {
      return res.status(400).json({ error: 'Type, latitude, longitude, and severity are required' });
    }

    const result = await pool.query(
      `INSERT INTO hazards (reported_by, type, latitude, longitude, severity, confidence, image_url, description, created_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW())
       RETURNING *`,
      [req.user.userId, type, latitude, longitude, severity, confidence || 0.0, imageUrl, description]
    );

    const hazard = result.rows[0];
    res.status(201).json({
      message: 'Hazard reported successfully',
      hazard: {
        id: hazard.id,
        type: hazard.type,
        latitude: parseFloat(hazard.latitude),
        longitude: parseFloat(hazard.longitude),
        severity: hazard.severity,
        confidence: parseFloat(hazard.confidence),
        image_url: hazard.image_url,
        imageUrl: hazard.image_url,
        description: hazard.description,
        is_verified: hazard.is_verified,
        isVerified: hazard.is_verified,
        verification_count: hazard.verification_count,
        verificationCount: hazard.verification_count,
        detected_at: hazard.created_at,
        detectedAt: hazard.created_at,
        created_at: hazard.created_at
      }
    });
  } catch (error) {
    console.error('Report hazard error:', error);
    res.status(500).json({ error: 'Failed to report hazard' });
  }
});

// Get nearby hazards
router.get('/nearby', authenticateToken, async (req, res) => {
  try {
    const { latitude, longitude, radius = 5 } = req.query; // radius in km

    if (!latitude || !longitude) {
      return res.status(400).json({ error: 'Latitude and longitude are required' });
    }

    const result = await pool.query(
      `SELECT h.*, u.display_name as reporter_name,
              calculate_distance($1, $2, h.latitude, h.longitude) as distance
       FROM hazards h
       LEFT JOIN users u ON h.reported_by = u.id
       WHERE calculate_distance($1, $2, h.latitude, h.longitude) <= $3
       ORDER BY distance ASC`,
      [parseFloat(latitude), parseFloat(longitude), parseFloat(radius)]
    );

    const hazards = result.rows.map(h => ({
      id: h.id,
      type: h.type,
      latitude: parseFloat(h.latitude),
      longitude: parseFloat(h.longitude),
      severity: h.severity,
      confidence: parseFloat(h.confidence),
      imageUrl: h.image_url,
      description: h.description,
      isVerified: h.is_verified,
      verificationCount: h.verification_count,
      reporterName: h.reporter_name,
      detectedAt: h.created_at,
      distance: parseFloat(h.distance).toFixed(2)
    }));

    res.json({ hazards, count: hazards.length });
  } catch (error) {
    console.error('Get nearby hazards error:', error);
    res.status(500).json({ error: 'Failed to get nearby hazards' });
  }
});

// Get all hazards
router.get('/', authenticateToken, async (req, res) => {
  try {
    const { type, severity, verified } = req.query;
    let query = 'SELECT h.*, u.display_name as reporter_name FROM hazards h LEFT JOIN users u ON h.reported_by = u.id WHERE 1=1';
    const params = [];
    let paramCount = 0;

    if (type) {
      paramCount++;
      query += ` AND h.type = $${paramCount}`;
      params.push(type);
    }

    if (severity) {
      paramCount++;
      query += ` AND h.severity = $${paramCount}`;
      params.push(severity);
    }

    if (verified !== undefined) {
      paramCount++;
      query += ` AND h.is_verified = $${paramCount}`;
      params.push(verified === 'true');
    }

    query += ' ORDER BY h.created_at DESC LIMIT 100';

    const result = await pool.query(query, params);

    const hazards = result.rows.map(h => ({
      id: h.id,
      type: h.type,
      latitude: parseFloat(h.latitude),
      longitude: parseFloat(h.longitude),
      severity: h.severity,
      confidence: parseFloat(h.confidence),
      imageUrl: h.image_url,
      description: h.description,
      isVerified: h.is_verified,
      verificationCount: h.verification_count,
      reporterName: h.reporter_name,
      detectedAt: h.created_at
    }));

    res.json({ hazards, count: hazards.length });
  } catch (error) {
    console.error('Get hazards error:', error);
    res.status(500).json({ error: 'Failed to get hazards' });
  }
});

// Get hazard by ID
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT h.*, u.display_name as reporter_name
       FROM hazards h
       LEFT JOIN users u ON h.reported_by = u.id
       WHERE h.id = $1`,
      [req.params.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Hazard not found' });
    }

    const h = result.rows[0];
    res.json({
      id: h.id,
      type: h.type,
      latitude: parseFloat(h.latitude),
      longitude: parseFloat(h.longitude),
      severity: h.severity,
      confidence: parseFloat(h.confidence),
      imageUrl: h.image_url,
      description: h.description,
      isVerified: h.is_verified,
      verificationCount: h.verification_count,
      reporterName: h.reporter_name,
      detectedAt: h.created_at
    });
  } catch (error) {
    console.error('Get hazard error:', error);
    res.status(500).json({ error: 'Failed to get hazard' });
  }
});

// Verify a hazard
router.post('/:id/verify', authenticateToken, async (req, res) => {
  try {
    const { verified } = req.body;

    // Check if user already verified this hazard
    const existingVerification = await pool.query(
      'SELECT id FROM hazard_verifications WHERE hazard_id = $1 AND verified_by = $2',
      [req.params.id, req.user.userId]
    );

    if (existingVerification.rows.length > 0) {
      return res.status(409).json({ error: 'You have already verified this hazard' });
    }

    // Add verification
    await pool.query(
      'INSERT INTO hazard_verifications (hazard_id, verified_by, verified) VALUES ($1, $2, $3)',
      [req.params.id, req.user.userId, verified !== false]
    );

    // Get updated hazard with verification count
    const result = await pool.query(
      `SELECT h.*, COUNT(hv.id) as verification_count
       FROM hazards h
       LEFT JOIN hazard_verifications hv ON h.id = hv.hazard_id AND hv.verified = true
       WHERE h.id = $1
       GROUP BY h.id`,
      [req.params.id]
    );

    const hazard = result.rows[0];
    res.json({
      message: 'Hazard verified successfully',
      hazard: {
        id: hazard.id,
        isVerified: hazard.is_verified,
        verificationCount: parseInt(hazard.verification_count)
      }
    });
  } catch (error) {
    console.error('Verify hazard error:', error);
    res.status(500).json({ error: 'Failed to verify hazard' });
  }
});

module.exports = router;
