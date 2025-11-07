const express = require('express');
const { pool } = require('../db');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Start a new trip
router.post('/start', authenticateToken, async (req, res) => {
  try {
    const { startLatitude, startLongitude, vehicleType } = req.body;

    if (!startLatitude || !startLongitude) {
      return res.status(400).json({ error: 'Start latitude and longitude are required' });
    }

    const result = await pool.query(
      `INSERT INTO trip_sessions (user_id, start_latitude, start_longitude, vehicle_type)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [req.user.userId, startLatitude, startLongitude, vehicleType]
    );

    const trip = result.rows[0];
    res.status(201).json({
      message: 'Trip started successfully',
      trip: {
        id: trip.id,
        startLatitude: parseFloat(trip.start_latitude),
        startLongitude: parseFloat(trip.start_longitude),
        vehicleType: trip.vehicle_type,
        startTime: trip.start_time
      }
    });
  } catch (error) {
    console.error('Start trip error:', error);
    res.status(500).json({ error: 'Failed to start trip' });
  }
});

// End a trip
router.post('/:id/end', authenticateToken, async (req, res) => {
  try {
    const { endLatitude, endLongitude, totalDistance, totalDuration } = req.body;

    if (!endLatitude || !endLongitude) {
      return res.status(400).json({ error: 'End latitude and longitude are required' });
    }

    const result = await pool.query(
      `UPDATE trip_sessions 
       SET end_latitude = $1, end_longitude = $2, end_time = NOW(),
           total_distance_km = $3, total_duration_minutes = $4
       WHERE id = $5 AND user_id = $6
       RETURNING *`,
      [endLatitude, endLongitude, totalDistance, totalDuration, req.params.id, req.user.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Trip not found' });
    }

    const trip = result.rows[0];
    res.json({
      message: 'Trip ended successfully',
      trip: {
        id: trip.id,
        startLatitude: parseFloat(trip.start_latitude),
        startLongitude: parseFloat(trip.start_longitude),
        endLatitude: parseFloat(trip.end_latitude),
        endLongitude: parseFloat(trip.end_longitude),
        totalDistance: parseFloat(trip.total_distance_km),
        totalDuration: trip.total_duration_minutes,
        hazardsEncountered: trip.hazards_encountered,
        damageScore: parseFloat(trip.damage_score),
        startTime: trip.start_time,
        endTime: trip.end_time
      }
    });
  } catch (error) {
    console.error('End trip error:', error);
    res.status(500).json({ error: 'Failed to end trip' });
  }
});

// Get trip history
router.get('/history', authenticateToken, async (req, res) => {
  try {
    const { limit = 20, offset = 0 } = req.query;

    const result = await pool.query(
      `SELECT * FROM trip_sessions 
       WHERE user_id = $1 
       ORDER BY start_time DESC 
       LIMIT $2 OFFSET $3`,
      [req.user.userId, limit, offset]
    );

    const trips = result.rows.map(t => ({
      id: t.id,
      startLatitude: parseFloat(t.start_latitude),
      startLongitude: parseFloat(t.start_longitude),
      endLatitude: t.end_latitude ? parseFloat(t.end_latitude) : null,
      endLongitude: t.end_longitude ? parseFloat(t.end_longitude) : null,
      totalDistance: t.total_distance_km ? parseFloat(t.total_distance_km) : null,
      totalDuration: t.total_duration_minutes,
      hazardsEncountered: t.hazards_encountered,
      damageScore: parseFloat(t.damage_score),
      vehicleType: t.vehicle_type,
      startTime: t.start_time,
      endTime: t.end_time
    }));

    res.json({ trips, count: trips.length });
  } catch (error) {
    console.error('Get trip history error:', error);
    res.status(500).json({ error: 'Failed to get trip history' });
  }
});

// Get trip statistics
router.get('/stats', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT 
         COUNT(*) as total_trips,
         COALESCE(SUM(total_distance_km), 0) as total_distance,
         COALESCE(SUM(total_duration_minutes), 0) as total_duration,
         COALESCE(SUM(hazards_encountered), 0) as total_hazards_encountered,
         COALESCE(AVG(damage_score), 0) as avg_damage_score
       FROM trip_sessions 
       WHERE user_id = $1 AND end_time IS NOT NULL`,
      [req.user.userId]
    );

    const stats = result.rows[0];
    res.json({
      totalTrips: parseInt(stats.total_trips),
      totalDistance: parseFloat(stats.total_distance).toFixed(2),
      totalDuration: parseInt(stats.total_duration),
      totalHazardsEncountered: parseInt(stats.total_hazards_encountered),
      avgDamageScore: parseFloat(stats.avg_damage_score).toFixed(2)
    });
  } catch (error) {
    console.error('Get trip stats error:', error);
    res.status(500).json({ error: 'Failed to get trip statistics' });
  }
});

module.exports = router;
