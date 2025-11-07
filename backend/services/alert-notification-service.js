/**
 * Alert Notification Service
 * Handles real-time alert notifications for HazardNet
 * Based on i.Mobilothon 5.0 requirements
 */

const { pool } = require('../db');

class AlertNotificationService {
  /**
   * Create proximity alert when user is near a hazard
   */
  static async createProximityAlert(userId, hazard, distance) {
    try {
      const title = `${hazard.severity} ${hazard.type} Ahead!`;
      const message = `${hazard.type} detected ${distance.toFixed(2)}km ahead. Drive carefully!`;
      
      await pool.query(
        `INSERT INTO alerts 
         (user_id, title, message, type, severity, hazard_id, metadata)
         VALUES ($1, $2, $3, $4, $5, $6, $7)`,
        [
          userId,
          title,
          message,
          'proximity',
          hazard.severity.toLowerCase(),
          hazard.id,
          {
            distance,
            hazard_type: hazard.type,
            location: {
              latitude: hazard.latitude,
              longitude: hazard.longitude
            }
          }
        ]
      );

      return { success: true, message: 'Proximity alert created' };
    } catch (error) {
      console.error('Create proximity alert error:', error);
      throw error;
    }
  }

  /**
   * Broadcast alert to all users in a specific area
   */
  static async broadcastAreaAlert(alertData) {
    try {
      const { title, message, type, severity, location, radius, metadata } = alertData;

      // Find all active users in the area
      const usersInArea = await pool.query(
        `SELECT DISTINCT ts.user_id, u.email, u.display_name
         FROM trip_sessions ts
         JOIN users u ON ts.user_id = u.id
         WHERE ts.end_time IS NULL
         AND calculate_distance($1, $2, ts.start_latitude, ts.start_longitude) <= $3`,
        [location.latitude, location.longitude, radius]
      );

      if (usersInArea.rows.length === 0) {
        return { success: true, recipientCount: 0, message: 'No active users in area' };
      }

      // Create alerts for all users
      const alertPromises = usersInArea.rows.map(user =>
        pool.query(
          `INSERT INTO alerts 
           (user_id, title, message, type, severity, metadata)
           VALUES ($1, $2, $3, $4, $5, $6)`,
          [user.user_id, title, message, type, severity, metadata]
        )
      );

      await Promise.all(alertPromises);

      return {
        success: true,
        recipientCount: usersInArea.rows.length,
        recipients: usersInArea.rows.map(u => ({
          userId: u.user_id,
          name: u.display_name,
          email: u.email
        }))
      };
    } catch (error) {
      console.error('Broadcast area alert error:', error);
      throw error;
    }
  }

  /**
   * Send emergency alert to all active users
   */
  static async sendEmergencyAlert(alertData) {
    try {
      const { title, message, metadata } = alertData;

      // Get all users with active trips
      const activeUsers = await pool.query(
        `SELECT DISTINCT ts.user_id, u.email, u.display_name
         FROM trip_sessions ts
         JOIN users u ON ts.user_id = u.id
         WHERE ts.end_time IS NULL`
      );

      if (activeUsers.rows.length === 0) {
        return { success: true, recipientCount: 0, message: 'No active users' };
      }

      // Create emergency alerts
      const alertPromises = activeUsers.rows.map(user =>
        pool.query(
          `INSERT INTO alerts 
           (user_id, title, message, type, severity, metadata)
           VALUES ($1, $2, $3, 'emergency', 'emergency', $4)`,
          [user.user_id, title, message, metadata]
        )
      );

      await Promise.all(alertPromises);

      return {
        success: true,
        recipientCount: activeUsers.rows.length,
        recipients: activeUsers.rows.map(u => ({
          userId: u.user_id,
          name: u.display_name,
          email: u.email
        }))
      };
    } catch (error) {
      console.error('Send emergency alert error:', error);
      throw error;
    }
  }

  /**
   * Check for hazards along a route and create alerts
   */
  static async checkRouteHazards(userId, waypoints, buffer = 0.5) {
    try {
      const hazardsAlongRoute = [];

      for (let i = 0; i < waypoints.length - 1; i++) {
        const start = waypoints[i];
        const end = waypoints[i + 1];

        const result = await pool.query(
          `SELECT h.*, 
                  calculate_distance($1, $2, h.latitude, h.longitude) as distance
           FROM hazards h
           WHERE (calculate_distance($1, $2, h.latitude, h.longitude) <= $3
                  OR calculate_distance($4, $5, h.latitude, h.longitude) <= $3)
           AND h.status = 'active'
           ORDER BY distance ASC`,
          [start.latitude, start.longitude, buffer, end.latitude, end.longitude]
        );

        hazardsAlongRoute.push(...result.rows);
      }

      // Remove duplicates
      const uniqueHazards = Array.from(
        new Map(hazardsAlongRoute.map(h => [h.id, h])).values()
      );

      // Create route alert if hazards found
      if (uniqueHazards.length > 0) {
        const severityCount = uniqueHazards.reduce((acc, h) => {
          acc[h.severity] = (acc[h.severity] || 0) + 1;
          return acc;
        }, {});

        const title = 'Route Hazards Detected';
        const message = `Found ${uniqueHazards.length} hazard(s) along your route: ${JSON.stringify(severityCount)}`;

        await pool.query(
          `INSERT INTO alerts 
           (user_id, title, message, type, severity, metadata)
           VALUES ($1, $2, $3, 'route', 'warning', $4)`,
          [
            userId,
            title,
            message,
            {
              hazardCount: uniqueHazards.length,
              severityBreakdown: severityCount,
              waypoints: waypoints.length
            }
          ]
        );
      }

      return {
        success: true,
        hazardsFound: uniqueHazards.length,
        hazards: uniqueHazards
      };
    } catch (error) {
      console.error('Check route hazards error:', error);
      throw error;
    }
  }

  /**
   * Monitor active trips and send proximity alerts
   */
  static async monitorActiveTrips() {
    try {
      // Get all active trips
      const activeTrips = await pool.query(
        `SELECT ts.*, u.id as user_id
         FROM trip_sessions ts
         JOIN users u ON ts.user_id = u.id
         WHERE ts.end_time IS NULL`
      );

      const proximityAlerts = [];

      for (const trip of activeTrips.rows) {
        // Find hazards within 1km of trip start location
        const nearbyHazards = await pool.query(
          `SELECT h.*, 
                  calculate_distance($1, $2, h.latitude, h.longitude) as distance
           FROM hazards h
           WHERE calculate_distance($1, $2, h.latitude, h.longitude) <= 1.0
           AND h.status = 'active'
           AND h.severity IN ('high', 'critical')
           ORDER BY distance ASC
           LIMIT 5`,
          [trip.start_latitude, trip.start_longitude]
        );

        // Create proximity alerts for critical hazards
        for (const hazard of nearbyHazards.rows) {
          await this.createProximityAlert(trip.user_id, hazard, hazard.distance);
          proximityAlerts.push({
            userId: trip.user_id,
            hazardId: hazard.id,
            distance: hazard.distance
          });
        }
      }

      return {
        success: true,
        tripsMonitored: activeTrips.rows.length,
        alertsCreated: proximityAlerts.length,
        alerts: proximityAlerts
      };
    } catch (error) {
      console.error('Monitor active trips error:', error);
      throw error;
    }
  }

  /**
   * Get alert summary for user
   */
  static async getAlertSummary(userId) {
    try {
      const summary = await pool.query(
        `SELECT 
          COUNT(*) as total_alerts,
          COUNT(*) FILTER (WHERE is_read = false) as unread_alerts,
          COUNT(*) FILTER (WHERE severity = 'emergency') as emergency_alerts,
          COUNT(*) FILTER (WHERE severity = 'critical') as critical_alerts,
          COUNT(*) FILTER (WHERE severity = 'warning') as warning_alerts,
          COUNT(*) FILTER (WHERE severity = 'info') as info_alerts,
          COUNT(*) FILTER (WHERE type = 'proximity') as proximity_alerts,
          COUNT(*) FILTER (WHERE type = 'weather') as weather_alerts,
          COUNT(*) FILTER (WHERE type = 'traffic') as traffic_alerts,
          COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '1 hour') as recent_alerts
         FROM alerts
         WHERE user_id = $1`,
        [userId]
      );

      return {
        success: true,
        summary: summary.rows[0]
      };
    } catch (error) {
      console.error('Get alert summary error:', error);
      throw error;
    }
  }

  /**
   * Cleanup old read alerts
   */
  static async cleanupOldAlerts(daysOld = 30) {
    try {
      const result = await pool.query(
        `DELETE FROM alerts 
         WHERE is_read = true 
         AND created_at < NOW() - INTERVAL '${daysOld} days'
         RETURNING id`
      );

      return {
        success: true,
        deletedCount: result.rowCount
      };
    } catch (error) {
      console.error('Cleanup old alerts error:', error);
      throw error;
    }
  }
}

module.exports = AlertNotificationService;
