-- ================================================================
-- HAZARDNET DATABASE SCHEMA FOR POSTGRESQL
-- Version: 1.0.0
-- Database: Neon PostgreSQL
-- Description: Complete schema for HazardNet road safety application
-- ================================================================

-- Enable UUID extension for generating unique IDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable PostGIS for geospatial queries (optional but recommended)
-- CREATE EXTENSION IF NOT EXISTS postgis;

-- ================================================================
-- USERS TABLE
-- Stores user profile and authentication information
-- ================================================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255), -- NULL for OAuth users
    display_name VARCHAR(100),
    phone_number VARCHAR(20),
    photo_url TEXT,
    vehicle_type VARCHAR(50) DEFAULT 'car' CHECK (vehicle_type IN ('car', 'bike', 'truck', 'bus', 'auto', 'other')),
    cumulative_damage_score INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_maintenance_check TIMESTAMP,
    driver_profile JSONB, -- Stores driving behavior analytics
    preferences JSONB, -- User preferences (notifications, language, etc.)
    is_premium BOOLEAN DEFAULT FALSE,
    total_hazards_reported INTEGER DEFAULT 0,
    verified_reports INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP
);

-- Indexes for users table
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at DESC);

-- ================================================================
-- HAZARDS TABLE
-- Stores detected and reported road hazards
-- ================================================================

CREATE TABLE hazards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type VARCHAR(50) NOT NULL CHECK (type IN (
        'pothole', 
        'speed_breaker', 
        'speed_breaker_unmarked', 
        'obstacle', 
        'closed_road', 
        'lane_blocked',
        'water_logging',
        'animal_crossing',
        'debris',
        'construction'
    )),
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    -- geolocation GEOGRAPHY(POINT, 4326), -- PostGIS point for spatial queries
    severity VARCHAR(20) DEFAULT 'medium' CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    confidence DECIMAL(4, 3) CHECK (confidence >= 0 AND confidence <= 1), -- ML confidence score
    detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    image_url TEXT, -- Blurred/processed image URL from cloud storage
    description TEXT,
    verification_count INTEGER DEFAULT 1,
    is_verified BOOLEAN DEFAULT FALSE,
    metadata JSONB, -- Additional sensor data, ML metadata
    lane VARCHAR(50), -- Specific lane information
    depth DECIMAL(5, 2), -- Pothole depth in cm (from depth estimation model)
    reported_by UUID REFERENCES users(id) ON DELETE SET NULL,
    reported_by_name VARCHAR(100), -- Cached for performance
    is_active BOOLEAN DEFAULT TRUE, -- For soft delete
    resolved_at TIMESTAMP, -- When hazard was resolved/fixed
    resolved_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for hazards table
CREATE INDEX idx_hazards_location ON hazards(latitude, longitude);
CREATE INDEX idx_hazards_type ON hazards(type);
CREATE INDEX idx_hazards_severity ON hazards(severity);
CREATE INDEX idx_hazards_detected_at ON hazards(detected_at DESC);
CREATE INDEX idx_hazards_reported_by ON hazards(reported_by);
CREATE INDEX idx_hazards_is_verified ON hazards(is_verified);
CREATE INDEX idx_hazards_is_active ON hazards(is_active);

-- Composite index for geospatial queries
CREATE INDEX idx_hazards_location_type ON hazards(latitude, longitude, type);

-- ================================================================
-- HAZARD_VERIFICATIONS TABLE
-- Tracks individual user verifications of hazards
-- ================================================================

CREATE TABLE hazard_verifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    hazard_id UUID NOT NULL REFERENCES hazards(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    verified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    confidence_boost DECIMAL(3, 2) DEFAULT 0.1, -- How much this verification increases confidence
    notes TEXT,
    UNIQUE(hazard_id, user_id) -- One verification per user per hazard
);

-- Indexes for verifications
CREATE INDEX idx_verifications_hazard ON hazard_verifications(hazard_id);
CREATE INDEX idx_verifications_user ON hazard_verifications(user_id);
CREATE INDEX idx_verifications_verified_at ON hazard_verifications(verified_at DESC);

-- ================================================================
-- ALERTS TABLE
-- Stores user alerts and notifications
-- ================================================================

CREATE TABLE alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL CHECK (type IN (
        'hazard_proximity',
        'maintenance_due',
        'system',
        'community',
        'achievement',
        'safety_tip'
    )),
    severity VARCHAR(20) DEFAULT 'info' CHECK (severity IN ('info', 'warning', 'critical')),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_read BOOLEAN DEFAULT FALSE,
    hazard_id UUID REFERENCES hazards(id) ON DELETE SET NULL,
    metadata JSONB,
    action_url TEXT, -- Deep link for action
    expires_at TIMESTAMP -- Auto-delete old alerts
);

-- Indexes for alerts
CREATE INDEX idx_alerts_user ON alerts(user_id);
CREATE INDEX idx_alerts_timestamp ON alerts(timestamp DESC);
CREATE INDEX idx_alerts_is_read ON alerts(is_read);
CREATE INDEX idx_alerts_type ON alerts(type);

-- ================================================================
-- TRIP_SESSIONS TABLE
-- Tracks user driving sessions for analytics
-- ================================================================

CREATE TABLE trip_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP,
    start_location JSONB, -- {lat, lng, address}
    end_location JSONB,
    distance_km DECIMAL(8, 2),
    duration_minutes INTEGER,
    hazards_detected INTEGER DEFAULT 0,
    average_speed DECIMAL(5, 2), -- km/h
    max_speed DECIMAL(5, 2),
    trip_metadata JSONB, -- Route, sensor data, etc.
    damage_score_increase INTEGER DEFAULT 0
);

-- Indexes for trip sessions
CREATE INDEX idx_trips_user ON trip_sessions(user_id);
CREATE INDEX idx_trips_start_time ON trip_sessions(start_time DESC);

-- ================================================================
-- SENSOR_DATA TABLE
-- Stores raw sensor data for analysis (optional - can be time-series DB)
-- ================================================================

CREATE TABLE sensor_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    trip_id UUID REFERENCES trip_sessions(id) ON DELETE CASCADE,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    accelerometer JSONB, -- {x, y, z}
    gyroscope JSONB, -- {x, y, z}
    speed DECIMAL(5, 2),
    heading DECIMAL(5, 2),
    impact_detected BOOLEAN DEFAULT FALSE,
    impact_severity DECIMAL(4, 2) -- G-force value
);

-- Indexes for sensor data
CREATE INDEX idx_sensor_user ON sensor_data(user_id);
CREATE INDEX idx_sensor_trip ON sensor_data(trip_id);
CREATE INDEX idx_sensor_timestamp ON sensor_data(timestamp DESC);
CREATE INDEX idx_sensor_impact ON sensor_data(impact_detected) WHERE impact_detected = TRUE;

-- ================================================================
-- MAINTENANCE_LOGS TABLE
-- Tracks vehicle maintenance based on damage scores
-- ================================================================

CREATE TABLE maintenance_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    maintenance_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    damage_score_before INTEGER,
    damage_score_after INTEGER DEFAULT 0,
    maintenance_type VARCHAR(100), -- 'routine', 'suspension', 'tires', etc.
    cost DECIMAL(10, 2),
    notes TEXT,
    service_center VARCHAR(200)
);

-- Indexes for maintenance logs
CREATE INDEX idx_maintenance_user ON maintenance_logs(user_id);
CREATE INDEX idx_maintenance_date ON maintenance_logs(maintenance_date DESC);

-- ================================================================
-- API_KEYS TABLE (for future B2B/Fleet management)
-- ================================================================

CREATE TABLE api_keys (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    organization_name VARCHAR(200),
    api_key VARCHAR(255) UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    rate_limit INTEGER DEFAULT 1000, -- Requests per hour
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    last_used TIMESTAMP
);

-- Indexes for API keys
CREATE INDEX idx_api_keys_key ON api_keys(api_key);
CREATE INDEX idx_api_keys_user ON api_keys(user_id);

-- ================================================================
-- VIEWS FOR COMMON QUERIES
-- ================================================================

-- View: Active hazards with reporter information
CREATE VIEW active_hazards_view AS
SELECT 
    h.id,
    h.type,
    h.latitude,
    h.longitude,
    h.severity,
    h.confidence,
    h.detected_at,
    h.image_url,
    h.description,
    h.verification_count,
    h.is_verified,
    h.lane,
    h.depth,
    u.display_name as reporter_name,
    u.email as reporter_email
FROM hazards h
LEFT JOIN users u ON h.reported_by = u.id
WHERE h.is_active = TRUE
ORDER BY h.detected_at DESC;

-- View: User statistics
CREATE VIEW user_stats_view AS
SELECT 
    u.id,
    u.display_name,
    u.email,
    u.total_hazards_reported,
    u.verified_reports,
    u.cumulative_damage_score,
    COUNT(DISTINCT ts.id) as total_trips,
    COALESCE(SUM(ts.distance_km), 0) as total_distance_km,
    COALESCE(AVG(ts.average_speed), 0) as avg_speed
FROM users u
LEFT JOIN trip_sessions ts ON u.id = ts.user_id
GROUP BY u.id, u.display_name, u.email, u.total_hazards_reported, 
         u.verified_reports, u.cumulative_damage_score;

-- ================================================================
-- FUNCTIONS
-- ================================================================

-- Function: Calculate distance between two points (Haversine formula)
CREATE OR REPLACE FUNCTION calculate_distance(
    lat1 DECIMAL, lon1 DECIMAL, 
    lat2 DECIMAL, lon2 DECIMAL
) RETURNS DECIMAL AS $$
DECLARE
    R DECIMAL := 6371; -- Earth radius in km
    dLat DECIMAL;
    dLon DECIMAL;
    a DECIMAL;
    c DECIMAL;
BEGIN
    dLat := radians(lat2 - lat1);
    dLon := radians(lon2 - lon1);
    a := sin(dLat/2) * sin(dLat/2) + 
         cos(radians(lat1)) * cos(radians(lat2)) * 
         sin(dLon/2) * sin(dLon/2);
    c := 2 * atan2(sqrt(a), sqrt(1-a));
    RETURN R * c;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function: Update hazard verification count
CREATE OR REPLACE FUNCTION update_hazard_verification_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE hazards
    SET verification_count = verification_count + 1,
        is_verified = (verification_count + 1 >= 3), -- Auto-verify after 3 reports
        updated_at = CURRENT_TIMESTAMP
    WHERE id = NEW.hazard_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Auto-update verification count
CREATE TRIGGER trigger_update_verification_count
AFTER INSERT ON hazard_verifications
FOR EACH ROW
EXECUTE FUNCTION update_hazard_verification_count();

-- Function: Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Auto-update updated_at on users
CREATE TRIGGER trigger_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Trigger: Auto-update updated_at on hazards
CREATE TRIGGER trigger_hazards_updated_at
BEFORE UPDATE ON hazards
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- ================================================================
-- INITIAL DATA / CONSTRAINTS
-- ================================================================

-- Add check constraint for valid coordinates
ALTER TABLE hazards ADD CONSTRAINT check_valid_latitude 
    CHECK (latitude >= -90 AND latitude <= 90);
    
ALTER TABLE hazards ADD CONSTRAINT check_valid_longitude 
    CHECK (longitude >= -180 AND longitude <= 180);

-- ================================================================
-- COMMENTS FOR DOCUMENTATION
-- ================================================================

COMMENT ON TABLE users IS 'Stores user profile and authentication information';
COMMENT ON TABLE hazards IS 'Stores detected and reported road hazards with geolocation';
COMMENT ON TABLE hazard_verifications IS 'Tracks multi-signature verification of hazards';
COMMENT ON TABLE alerts IS 'User notifications for proximity alerts and maintenance';
COMMENT ON TABLE trip_sessions IS 'Driving session analytics and tracking';
COMMENT ON TABLE sensor_data IS 'Raw sensor data from accelerometer and gyroscope';
COMMENT ON TABLE maintenance_logs IS 'Vehicle maintenance history and damage tracking';

COMMENT ON COLUMN hazards.confidence IS 'ML model confidence score (0.0 - 1.0)';
COMMENT ON COLUMN hazards.verification_count IS 'Number of users who verified this hazard';
COMMENT ON COLUMN users.cumulative_damage_score IS 'Total damage points accumulated from road hazards';
COMMENT ON COLUMN sensor_data.impact_severity IS 'G-force value of impact detection';

-- ================================================================
-- COMPLETION MESSAGE
-- ================================================================

SELECT 'HazardNet database schema created successfully! 🚗💨' AS status;
