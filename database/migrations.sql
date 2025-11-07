-- ================================================================
-- DATABASE MIGRATIONS FOR NEW FEATURES
-- i.Mobilothon 5.0 Enhanced Features
-- ================================================================

-- Add photo upload support (multiple photos per hazard)
CREATE TABLE IF NOT EXISTS hazard_photos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    hazard_id UUID NOT NULL REFERENCES hazards(id) ON DELETE CASCADE,
    photo_url TEXT NOT NULL,
    uploaded_by UUID REFERENCES users(id) ON DELETE SET NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_primary BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_hazard_photos_hazard ON hazard_photos(hazard_id);

-- Add upvote/downvote system for hazard verification
CREATE TABLE IF NOT EXISTS hazard_votes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    hazard_id UUID NOT NULL REFERENCES hazards(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    vote_type VARCHAR(10) NOT NULL CHECK (vote_type IN ('upvote', 'downvote')),
    voted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(hazard_id, user_id)
);

CREATE INDEX idx_hazard_votes_hazard ON hazard_votes(hazard_id);
CREATE INDEX idx_hazard_votes_user ON hazard_votes(user_id);

-- Add columns for vote counts to hazards table
ALTER TABLE hazards 
ADD COLUMN IF NOT EXISTS upvotes INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS downvotes INTEGER DEFAULT 0;

-- Add gamification: user points and badges
CREATE TABLE IF NOT EXISTS user_points (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    total_points INTEGER DEFAULT 0,
    level INTEGER DEFAULT 1,
    reports_count INTEGER DEFAULT 0,
    verifications_count INTEGER DEFAULT 0,
    accuracy_score DECIMAL(4, 3) DEFAULT 1.0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_badges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    badge_type VARCHAR(50) NOT NULL,
    badge_name VARCHAR(100) NOT NULL,
    earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB
);

CREATE INDEX idx_user_badges_user ON user_badges(user_id);
CREATE INDEX idx_user_badges_type ON user_badges(badge_type);

-- Add leaderboard view
CREATE OR REPLACE VIEW leaderboard AS
SELECT 
    u.id,
    u.username,
    u.full_name,
    COALESCE(up.total_points, 0) as points,
    COALESCE(up.level, 1) as level,
    COALESCE(up.reports_count, 0) as reports,
    COALESCE(up.verifications_count, 0) as verifications,
    COALESCE(up.accuracy_score, 1.0) as accuracy,
    COUNT(DISTINCT ub.id) as badge_count
FROM users u
LEFT JOIN user_points up ON u.id = up.user_id
LEFT JOIN user_badges ub ON u.id = ub.user_id
WHERE u.is_active = TRUE
GROUP BY u.id, u.username, u.full_name, up.total_points, up.level, 
         up.reports_count, up.verifications_count, up.accuracy_score
ORDER BY points DESC, reports DESC;

-- Emergency SOS contacts
CREATE TABLE IF NOT EXISTS emergency_contacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    contact_name VARCHAR(100) NOT NULL,
    contact_phone VARCHAR(20) NOT NULL,
    relationship VARCHAR(50),
    priority INTEGER DEFAULT 1,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_emergency_contacts_user ON emergency_contacts(user_id);

-- SOS alerts table
CREATE TABLE IF NOT EXISTS sos_alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    alert_type VARCHAR(50) DEFAULT 'emergency',
    message TEXT,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'resolved', 'cancelled')),
    triggered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP,
    metadata JSONB
);

CREATE INDEX idx_sos_alerts_user ON sos_alerts(user_id);
CREATE INDEX idx_sos_alerts_status ON sos_alerts(status);
CREATE INDEX idx_sos_alerts_triggered_at ON sos_alerts(triggered_at DESC);

-- Authority/Government users table
CREATE TABLE IF NOT EXISTS authority_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    authority_type VARCHAR(50) NOT NULL CHECK (authority_type IN (
        'police', 'traffic_police', 'municipality', 'road_dept', 'emergency_services'
    )),
    jurisdiction VARCHAR(200),
    badge_number VARCHAR(50),
    department VARCHAR(100),
    is_verified BOOLEAN DEFAULT FALSE,
    verified_at TIMESTAMP,
    verified_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

CREATE INDEX idx_authority_users_type ON authority_users(authority_type);
CREATE INDEX idx_authority_users_jurisdiction ON authority_users(jurisdiction);

-- Authority actions on hazards
CREATE TABLE IF NOT EXISTS hazard_authority_actions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    hazard_id UUID NOT NULL REFERENCES hazards(id) ON DELETE CASCADE,
    authority_id UUID NOT NULL REFERENCES authority_users(id) ON DELETE CASCADE,
    action_type VARCHAR(50) NOT NULL CHECK (action_type IN (
        'acknowledged', 'investigating', 'in_progress', 'resolved', 'rejected'
    )),
    notes TEXT,
    estimated_resolution_time TIMESTAMP,
    action_taken_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_hazard_authority_actions_hazard ON hazard_authority_actions(hazard_id);
CREATE INDEX idx_hazard_authority_actions_authority ON hazard_authority_actions(authority_id);

-- Weather alerts integration
CREATE TABLE IF NOT EXISTS weather_alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    radius_km DECIMAL(6, 2) DEFAULT 10.0,
    weather_type VARCHAR(50) NOT NULL CHECK (weather_type IN (
        'heavy_rain', 'fog', 'ice', 'snow', 'storm', 'extreme_heat', 'flood'
    )),
    severity VARCHAR(20) NOT NULL CHECK (severity IN ('low', 'medium', 'high', 'extreme')),
    message TEXT NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    source VARCHAR(50), -- API source
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_weather_alerts_location ON weather_alerts(latitude, longitude);
CREATE INDEX idx_weather_alerts_active ON weather_alerts(is_active);
CREATE INDEX idx_weather_alerts_type ON weather_alerts(weather_type);

-- Function to calculate user points
CREATE OR REPLACE FUNCTION calculate_user_points(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
    total_points INTEGER;
BEGIN
    total_points := (
        -- Points for reports
        (SELECT COUNT(*) * 10 FROM hazards WHERE reported_by = p_user_id AND is_active = TRUE) +
        -- Points for verified reports
        (SELECT COUNT(*) * 20 FROM hazards WHERE reported_by = p_user_id AND is_verified = TRUE) +
        -- Points for verifications
        (SELECT COUNT(*) * 5 FROM hazard_verifications WHERE user_id = p_user_id) +
        -- Points for upvotes received
        (SELECT COUNT(*) * 2 FROM hazard_votes hv 
         JOIN hazards h ON hv.hazard_id = h.id 
         WHERE h.reported_by = p_user_id AND hv.vote_type = 'upvote')
    );
    
    RETURN COALESCE(total_points, 0);
END;
$$ LANGUAGE plpgsql;

-- Function to award badges
CREATE OR REPLACE FUNCTION check_and_award_badges(p_user_id UUID)
RETURNS VOID AS $$
DECLARE
    report_count INTEGER;
    verification_count INTEGER;
    verified_report_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO report_count FROM hazards WHERE reported_by = p_user_id;
    SELECT COUNT(*) INTO verification_count FROM hazard_verifications WHERE user_id = p_user_id;
    SELECT COUNT(*) INTO verified_report_count FROM hazards WHERE reported_by = p_user_id AND is_verified = TRUE;
    
    -- First Report Badge
    IF report_count >= 1 AND NOT EXISTS (
        SELECT 1 FROM user_badges WHERE user_id = p_user_id AND badge_type = 'first_report'
    ) THEN
        INSERT INTO user_badges (user_id, badge_type, badge_name)
        VALUES (p_user_id, 'first_report', 'Road Warrior');
    END IF;
    
    -- 10 Reports Badge
    IF report_count >= 10 AND NOT EXISTS (
        SELECT 1 FROM user_badges WHERE user_id = p_user_id AND badge_type = '10_reports'
    ) THEN
        INSERT INTO user_badges (user_id, badge_type, badge_name)
        VALUES (p_user_id, '10_reports', 'Safety Champion');
    END IF;
    
    -- 50 Reports Badge
    IF report_count >= 50 AND NOT EXISTS (
        SELECT 1 FROM user_badges WHERE user_id = p_user_id AND badge_type = '50_reports'
    ) THEN
        INSERT INTO user_badges (user_id, badge_type, badge_name)
        VALUES (p_user_id, '50_reports', 'Guardian of Roads');
    END IF;
    
    -- Verification Expert Badge
    IF verification_count >= 25 AND NOT EXISTS (
        SELECT 1 FROM user_badges WHERE user_id = p_user_id AND badge_type = 'verification_expert'
    ) THEN
        INSERT INTO user_badges (user_id, badge_type, badge_name)
        VALUES (p_user_id, 'verification_expert', 'Truth Seeker');
    END IF;
    
    -- Verified Reporter Badge
    IF verified_report_count >= 5 AND NOT EXISTS (
        SELECT 1 FROM user_badges WHERE user_id = p_user_id AND badge_type = 'verified_reporter'
    ) THEN
        INSERT INTO user_badges (user_id, badge_type, badge_name)
        VALUES (p_user_id, 'verified_reporter', 'Trusted Reporter');
    END IF;
END;
$$ LANGUAGE plpgsql;
