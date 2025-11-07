const express = require('express');
const { pool } = require('../db');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Upload sensor data
router.post('/upload', authenticateToken, async (req, res) => {
  try {
    const { tripId, latitude, longitude, accelerometerX, accelerometerY, accelerometerZ, gyroscopeX, gyroscopeY, gyroscopeZ, speed, impactDetected } = req.body;

    if (!latitude || !longitude) {
      return res.status(400).json({ error: 'Latitude and longitude are required' });
    }

    const result = await pool.query(
      `INSERT INTO sensor_data 
       (trip_id, latitude, longitude, accelerometer_x, accelerometer_y, accelerometer_z, 
        gyroscope_x, gyroscope_y, gyroscope_z, speed, impact_detected)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
       RETURNING *`,
      [tripId, latitude, longitude, accelerometerX, accelerometerY, accelerometerZ, 
       gyroscopeX, gyroscopeY, gyroscopeZ, speed, impactDetected || false]
    );

    const data = result.rows[0];
    res.status(201).json({
      message: 'Sensor data uploaded successfully',
      data: {
        id: data.id,
        impactDetected: data.impact_detected,
        timestamp: data.timestamp
      }
    });
  } catch (error) {
    console.error('Upload sensor data error:', error);
    res.status(500).json({ error: 'Failed to upload sensor data' });
  }
});

// Upload batch sensor data
router.post('/upload/batch', authenticateToken, async (req, res) => {
  try {
    const { tripId, sensorData } = req.body;

    if (!Array.isArray(sensorData) || sensorData.length === 0) {
      return res.status(400).json({ error: 'Sensor data array is required' });
    }

    const values = sensorData.map((data, index) => {
      const params = [
        tripId,
        data.latitude,
        data.longitude,
        data.accelerometerX,
        data.accelerometerY,
        data.accelerometerZ,
        data.gyroscopeX,
        data.gyroscopeY,
        data.gyroscopeZ,
        data.speed,
        data.impactDetected || false
      ];
      const placeholders = params.map((_, i) => `$${index * 11 + i + 1}`).join(', ');
      return `(${placeholders})`;
    }).join(', ');

    const allParams = sensorData.flatMap(data => [
      tripId,
      data.latitude,
      data.longitude,
      data.accelerometerX,
      data.accelerometerY,
      data.accelerometerZ,
      data.gyroscopeX,
      data.gyroscopeY,
      data.gyroscopeZ,
      data.speed,
      data.impactDetected || false
    ]);

    await pool.query(
      `INSERT INTO sensor_data 
       (trip_id, latitude, longitude, accelerometer_x, accelerometer_y, accelerometer_z, 
        gyroscope_x, gyroscope_y, gyroscope_z, speed, impact_detected)
       VALUES ${values}`,
      allParams
    );

    res.status(201).json({
      message: 'Batch sensor data uploaded successfully',
      count: sensorData.length
    });
  } catch (error) {
    console.error('Upload batch sensor data error:', error);
    res.status(500).json({ error: 'Failed to upload batch sensor data' });
  }
});

// Get impact detections for a trip
router.get('/impacts/:tripId', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT * FROM sensor_data 
       WHERE trip_id = $1 AND impact_detected = true 
       ORDER BY timestamp DESC`,
      [req.params.tripId]
    );

    const impacts = result.rows.map(i => ({
      id: i.id,
      latitude: parseFloat(i.latitude),
      longitude: parseFloat(i.longitude),
      accelerometerX: parseFloat(i.accelerometer_x),
      accelerometerY: parseFloat(i.accelerometer_y),
      accelerometerZ: parseFloat(i.accelerometer_z),
      speed: parseFloat(i.speed),
      timestamp: i.timestamp
    }));

    res.json({ impacts, count: impacts.length });
  } catch (error) {
    console.error('Get impacts error:', error);
    res.status(500).json({ error: 'Failed to get impact detections' });
  }
});

module.exports = router;
