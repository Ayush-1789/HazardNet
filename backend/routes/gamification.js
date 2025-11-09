const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const { authenticateToken } = require('../middleware/auth');
const { pool } = require('../db');

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/hazard-photos/');
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'hazard-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const fileFilter = (req, file, cb) => {
  const allowedTypes = /jpeg|jpg|png|webp/;
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  const mimetype = allowedTypes.test((file.mimetype || '').toLowerCase());

  // Log file info for easier debugging of rejected uploads
  console.log('Upload file filter:', { originalname: file.originalname, mimetype: file.mimetype, extname, mimetypeMatch: mimetype });

  // Accept if either the extension OR the provided mimetype matches allowed image types.
  if (extname || mimetype) {
    return cb(null, true);
  }

  cb(new Error('Only image files (jpeg, jpg, png, webp) are allowed!'));
};

const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
  fileFilter: fileFilter
});

// ================================================================
// PHOTO UPLOAD ROUTES
// ================================================================

// Upload photos for a hazard
router.post('/:hazardId/photos', authenticateToken, upload.array('photos', 5), async (req, res) => {
  const client = await pool.connect();
  try {
    const { hazardId } = req.params;
    const userId = req.user.userId;
    const files = req.files;

    if (!files || files.length === 0) {
      return res.status(400).json({ error: 'No photos uploaded' });
    }

    // Check if hazard exists
    const hazardCheck = await client.query(
      'SELECT id FROM hazards WHERE id = $1',
      [hazardId]
    );

    if (hazardCheck.rows.length === 0) {
      return res.status(404).json({ error: 'Hazard not found' });
    }

    // Insert photos
    const photoInserts = files.map((file, index) => {
      const photoUrl = `/uploads/hazard-photos/${file.filename}`;
      const isPrimary = index === 0; // First photo is primary
      
      return client.query(
        `INSERT INTO hazard_photos (hazard_id, photo_url, uploaded_by, is_primary)
         VALUES ($1, $2, $3, $4)
         RETURNING *`,
        [hazardId, photoUrl, userId, isPrimary]
      );
    });

    const results = await Promise.all(photoInserts);
    const photos = results.map(r => r.rows[0]);

    // Update hazard's primary image_url if not set
    if (photos.length > 0) {
      await client.query(
        `UPDATE hazards SET image_url = $1 WHERE id = $2 AND image_url IS NULL`,
        [photos[0].photo_url, hazardId]
      );
    }

    res.status(201).json({
      message: 'Photos uploaded successfully',
      photos: photos
    });

  } catch (error) {
    console.error('Photo upload error:', error);
    res.status(500).json({ error: 'Failed to upload photos' });
  } finally {
    client.release();
  }
});

// Get photos for a hazard
router.get('/:hazardId/photos', async (req, res) => {
  try {
    const { hazardId } = req.params;
    
    const result = await pool.query(
      `SELECT hp.*, u.display_name as uploaded_by_name
       FROM hazard_photos hp
       LEFT JOIN users u ON hp.uploaded_by = u.id
       WHERE hp.hazard_id = $1
       ORDER BY hp.is_primary DESC, hp.uploaded_at DESC`,
      [hazardId]
    );

    res.json({ photos: result.rows });

  } catch (error) {
    console.error('Get photos error:', error);
    res.status(500).json({ error: 'Failed to retrieve photos' });
  }
});

// ================================================================
// VOTING ROUTES (Upvote/Downvote)
// ================================================================

// Vote on a hazard
router.post('/:hazardId/vote', authenticateToken, async (req, res) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    
    const { hazardId } = req.params;
    const { voteType } = req.body; // 'upvote' or 'downvote'
    const userId = req.user.userId;

    if (!['upvote', 'downvote'].includes(voteType)) {
      return res.status(400).json({ error: 'Invalid vote type' });
    }

    // Check if user already voted
    const existingVote = await client.query(
      'SELECT * FROM hazard_votes WHERE hazard_id = $1 AND user_id = $2',
      [hazardId, userId]
    );

    if (existingVote.rows.length > 0) {
      const oldVote = existingVote.rows[0].vote_type;
      
      if (oldVote === voteType) {
        // Remove vote (toggle off)
        await client.query(
          'DELETE FROM hazard_votes WHERE hazard_id = $1 AND user_id = $2',
          [hazardId, userId]
        );
        
        // Update hazard vote count
        await client.query(
          `UPDATE hazards SET ${voteType}s = ${voteType}s - 1 WHERE id = $1`,
          [hazardId]
        );

        await client.query('COMMIT');
        return res.json({ message: 'Vote removed', action: 'removed' });
        
      } else {
        // Change vote
        await client.query(
          'UPDATE hazard_votes SET vote_type = $1, voted_at = CURRENT_TIMESTAMP WHERE hazard_id = $2 AND user_id = $3',
          [voteType, hazardId, userId]
        );
        
        // Update hazard vote counts (decrement old, increment new)
        const oldVoteColumn = oldVote + 's';
        const newVoteColumn = voteType + 's';
        await client.query(
          `UPDATE hazards SET ${oldVoteColumn} = ${oldVoteColumn} - 1, ${newVoteColumn} = ${newVoteColumn} + 1 WHERE id = $1`,
          [hazardId]
        );

        await client.query('COMMIT');
        return res.json({ message: 'Vote changed', action: 'changed', voteType });
      }
    } else {
      // New vote
      await client.query(
        `INSERT INTO hazard_votes (hazard_id, user_id, vote_type)
         VALUES ($1, $2, $3)`,
        [hazardId, userId, voteType]
      );
      
      // Update hazard vote count
      await client.query(
        `UPDATE hazards SET ${voteType}s = ${voteType}s + 1 WHERE id = $1`,
        [hazardId]
      );

      // Update confidence based on votes
      await client.query(
        `UPDATE hazards 
         SET confidence = LEAST(1.0, 0.5 + (upvotes::decimal / GREATEST(upvotes + downvotes, 1)) * 0.5)
         WHERE id = $1`,
        [hazardId]
      );

      await client.query('COMMIT');
      res.json({ message: 'Vote recorded', action: 'added', voteType });
    }

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Vote error:', error);
    res.status(500).json({ error: 'Failed to record vote' });
  } finally {
    client.release();
  }
});

// Get vote status for a hazard
router.get('/:hazardId/vote-status', authenticateToken, async (req, res) => {
  try {
    const { hazardId } = req.params;
    const userId = req.user.userId;

    const result = await pool.query(
      `SELECT h.upvotes, h.downvotes, hv.vote_type as user_vote
       FROM hazards h
       LEFT JOIN hazard_votes hv ON h.id = hv.hazard_id AND hv.user_id = $2
       WHERE h.id = $1`,
      [hazardId, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Hazard not found' });
    }

    res.json(result.rows[0]);

  } catch (error) {
    console.error('Vote status error:', error);
    res.status(500).json({ error: 'Failed to get vote status' });
  }
});

// ================================================================
// GAMIFICATION ROUTES
// ================================================================

// Get user points and level
router.get('/user/:userId/points', async (req, res) => {
  try {
    const { userId } = req.params;

    // Update or create user points
    const points = await pool.query(
      'SELECT calculate_user_points($1) as total_points',
      [userId]
    );

    const totalPoints = points.rows[0].total_points;
    const level = Math.floor(totalPoints / 100) + 1;

    // Upsert user_points table
    await pool.query(
      `INSERT INTO user_points (user_id, total_points, level, last_updated)
       VALUES ($1, $2, $3, CURRENT_TIMESTAMP)
       ON CONFLICT (user_id) 
       DO UPDATE SET total_points = $2, level = $3, last_updated = CURRENT_TIMESTAMP`,
      [userId, totalPoints, level]
    );

    res.json({
      userId,
      totalPoints,
      level,
      nextLevelPoints: (level * 100),
      pointsToNextLevel: (level * 100) - totalPoints
    });

  } catch (error) {
    console.error('Get points error:', error);
    res.status(500).json({ error: 'Failed to get user points' });
  }
});

// Get user badges
router.get('/user/:userId/badges', async (req, res) => {
  try {
    const { userId } = req.params;

    // Check and award new badges
    await pool.query('SELECT check_and_award_badges($1)', [userId]);

    // Get all badges
    const result = await pool.query(
      `SELECT * FROM user_badges 
       WHERE user_id = $1 
       ORDER BY earned_at DESC`,
      [userId]
    );

    res.json({ badges: result.rows });

  } catch (error) {
    console.error('Get badges error:', error);
    res.status(500).json({ error: 'Failed to get badges' });
  }
});

// Get leaderboard
router.get('/leaderboard', async (req, res) => {
  try {
    const { limit = 50, offset = 0 } = req.query;

    const result = await pool.query(
      `SELECT * FROM leaderboard LIMIT $1 OFFSET $2`,
      [limit, offset]
    );

    res.json({ leaderboard: result.rows });

  } catch (error) {
    console.error('Leaderboard error:', error);
    res.status(500).json({ error: 'Failed to get leaderboard' });
  }
});

// Get user rank
router.get('/user/:userId/rank', async (req, res) => {
  try {
    const { userId } = req.params;

    const result = await pool.query(
      `WITH ranked_users AS (
        SELECT id, points, ROW_NUMBER() OVER (ORDER BY points DESC) as rank
        FROM leaderboard
      )
      SELECT rank FROM ranked_users WHERE id = $1`,
      [userId]
    );

    if (result.rows.length === 0) {
      return res.json({ rank: null, message: 'User not ranked yet' });
    }

    res.json({ userId, rank: result.rows[0].rank });

  } catch (error) {
    console.error('Get rank error:', error);
    res.status(500).json({ error: 'Failed to get user rank' });
  }
});

module.exports = router;
