-- ================================================================
-- HAZARDNET DATABASE SEED DATA
-- Version: 1.0.0
-- Description: Sample data for testing and development
-- ================================================================

-- ================================================================
-- SEED USERS
-- ================================================================

INSERT INTO users (id, email, display_name, phone_number, vehicle_type, cumulative_damage_score, is_premium, total_hazards_reported, verified_reports, driver_profile, preferences) VALUES
(
    '11111111-1111-1111-1111-111111111111',
    'ayush.sharma@hazardnet.com',
    'Ayush Sharma',
    '+919876543210',
    'car',
    245,
    TRUE,
    28,
    22,
    '{"driving_score": 92, "harsh_braking_count": 3, "overspeeding_count": 1, "total_km": 1547}'::JSONB,
    '{"notifications": true, "proximity_radius": 500, "language": "en", "theme": "dark"}'::JSONB
),
(
    '22222222-2222-2222-2222-222222222222',
    'priya.verma@gmail.com',
    'Priya Verma',
    '+919123456789',
    'bike',
    180,
    FALSE,
    15,
    12,
    '{"driving_score": 87, "harsh_braking_count": 5, "overspeeding_count": 2, "total_km": 892}'::JSONB,
    '{"notifications": true, "proximity_radius": 300, "language": "hi", "theme": "light"}'::JSONB
),
(
    '33333333-3333-3333-3333-333333333333',
    'rahul.kumar@outlook.com',
    'Rahul Kumar',
    '+919998887776',
    'auto',
    520,
    FALSE,
    42,
    38,
    '{"driving_score": 78, "harsh_braking_count": 12, "overspeeding_count": 8, "total_km": 3245}'::JSONB,
    '{"notifications": true, "proximity_radius": 400, "language": "en", "theme": "auto"}'::JSONB
),
(
    '44444444-4444-4444-4444-444444444444',
    'sneha.patel@yahoo.com',
    'Sneha Patel',
    '+918887776665',
    'car',
    95,
    TRUE,
    8,
    7,
    '{"driving_score": 95, "harsh_braking_count": 1, "overspeeding_count": 0, "total_km": 456}'::JSONB,
    '{"notifications": true, "proximity_radius": 600, "language": "gu", "theme": "light"}'::JSONB
),
(
    '55555555-5555-5555-5555-555555555555',
    'test.user@hazardnet.com',
    'Test User',
    '+911234567890',
    'truck',
    1250,
    FALSE,
    95,
    75,
    '{"driving_score": 68, "harsh_braking_count": 45, "overspeeding_count": 23, "total_km": 12540}'::JSONB,
    '{"notifications": false, "proximity_radius": 1000, "language": "en", "theme": "dark"}'::JSONB
);

-- ================================================================
-- SEED HAZARDS (Various locations in India)
-- ================================================================

INSERT INTO hazards (id, type, latitude, longitude, severity, confidence, description, verification_count, is_verified, metadata, lane, depth, reported_by, reported_by_name) VALUES
-- Delhi NCR
(
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'pothole',
    28.6139,
    77.2090,
    'high',
    0.92,
    'Large pothole near ITO intersection, causes significant vehicle damage',
    5,
    TRUE,
    '{"ml_model": "yolov8", "detection_time_ms": 45, "image_quality": "high"}'::JSONB,
    'left_lane',
    12.5,
    '11111111-1111-1111-1111-111111111111',
    'Ayush Sharma'
),
(
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'speed_breaker_unmarked',
    28.7041,
    77.1025,
    'critical',
    0.88,
    'Unmarked speed breaker on main road near Metro station',
    8,
    TRUE,
    '{"ml_model": "yolov8", "detection_time_ms": 52, "image_quality": "medium"}'::JSONB,
    'center',
    NULL,
    '22222222-2222-2222-2222-222222222222',
    'Priya Verma'
),
-- Mumbai
(
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    'water_logging',
    19.0760,
    72.8777,
    'high',
    0.95,
    'Water logging after monsoon rain, reduces visibility',
    12,
    TRUE,
    '{"ml_model": "segmentation", "water_depth_cm": 25, "image_quality": "high"}'::JSONB,
    'both_lanes',
    NULL,
    '33333333-3333-3333-3333-333333333333',
    'Rahul Kumar'
),
(
    'dddddddd-dddd-dddd-dddd-dddddddddddd',
    'lane_blocked',
    19.1136,
    72.8697,
    'medium',
    0.78,
    'Construction debris blocking right lane',
    3,
    TRUE,
    '{"ml_model": "yolov8", "detection_time_ms": 67, "obstacle_type": "construction"}'::JSONB,
    'right_lane',
    NULL,
    '44444444-4444-4444-4444-444444444444',
    'Sneha Patel'
),
-- Bangalore
(
    'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
    'pothole',
    12.9716,
    77.5946,
    'medium',
    0.85,
    'Medium-sized pothole on Outer Ring Road',
    2,
    FALSE,
    '{"ml_model": "yolov8", "detection_time_ms": 38, "image_quality": "medium"}'::JSONB,
    'center',
    8.3,
    '55555555-5555-5555-5555-555555555555',
    'Test User'
),
(
    'ffffffff-ffff-ffff-ffff-ffffffffffff',
    'speed_breaker',
    12.9352,
    77.6245,
    'low',
    0.91,
    'Marked speed breaker near school zone',
    6,
    TRUE,
    '{"ml_model": "yolov8", "detection_time_ms": 41, "painted": true}'::JSONB,
    'center',
    NULL,
    '11111111-1111-1111-1111-111111111111',
    'Ayush Sharma'
),
-- Pune
(
    'gggggggg-gggg-gggg-gggg-gggggggggggg',
    'debris',
    18.5204,
    73.8567,
    'high',
    0.82,
    'Fallen tree branch blocking half the road',
    4,
    TRUE,
    '{"ml_model": "yolov8", "detection_time_ms": 78, "obstacle_size": "large"}'::JSONB,
    'left_lane',
    NULL,
    '22222222-2222-2222-2222-222222222222',
    'Priya Verma'
),
(
    'hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh',
    'animal_crossing',
    18.4574,
    73.8544,
    'medium',
    0.76,
    'Stray cattle frequently cross at this location',
    7,
    TRUE,
    '{"ml_model": "yolov8", "detection_time_ms": 92, "animal_type": "cattle"}'::JSONB,
    'both_lanes',
    NULL,
    '33333333-3333-3333-3333-333333333333',
    'Rahul Kumar'
),
-- Hyderabad
(
    'iiiiiiii-iiii-iiii-iiii-iiiiiiiiiiii',
    'pothole',
    17.3850,
    78.4867,
    'critical',
    0.94,
    'Extremely deep pothole causing tire damage',
    15,
    TRUE,
    '{"ml_model": "depth_estimation", "detection_time_ms": 48, "damage_reports": 8}'::JSONB,
    'right_lane',
    18.7,
    '44444444-4444-4444-4444-444444444444',
    'Sneha Patel'
),
(
    'jjjjjjjj-jjjj-jjjj-jjjj-jjjjjjjjjjjj',
    'closed_road',
    17.4239,
    78.4738,
    'critical',
    0.98,
    'Road closed for metro construction, diverted route available',
    20,
    TRUE,
    '{"ml_model": "sign_detection", "detection_time_ms": 35, "diversion_available": true}'::JSONB,
    'all_lanes',
    NULL,
    '55555555-5555-5555-5555-555555555555',
    'Test User'
);

-- ================================================================
-- SEED HAZARD VERIFICATIONS
-- ================================================================

INSERT INTO hazard_verifications (hazard_id, user_id, confidence_boost, notes) VALUES
-- Pothole at ITO verified by multiple users
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '22222222-2222-2222-2222-222222222222', 0.15, 'Confirmed, very deep pothole'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '33333333-3333-3333-3333-333333333333', 0.12, 'Yes, damaged my tire here'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '44444444-4444-4444-4444-444444444444', 0.10, 'Still there as of today'),

-- Unmarked speed breaker verified
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', 0.18, 'Very dangerous, need marking'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '33333333-3333-3333-3333-333333333333', 0.14, 'Confirmed unmarked'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '55555555-5555-5555-5555-555555555555', 0.16, 'Saw it yesterday'),

-- Water logging in Mumbai
('cccccccc-cccc-cccc-cccc-cccccccccccc', '11111111-1111-1111-1111-111111111111', 0.20, 'Severe waterlogging after rain'),
('cccccccc-cccc-cccc-cccc-cccccccccccc', '22222222-2222-2222-2222-222222222222', 0.15, 'Avoid this route during monsoon'),

-- Critical pothole in Hyderabad
('iiiiiiii-iiii-iiii-iiii-iiiiiiiiiiii', '11111111-1111-1111-1111-111111111111', 0.22, 'Damaged my car suspension'),
('iiiiiiii-iiii-iiii-iiii-iiiiiiiiiiii', '22222222-2222-2222-2222-222222222222', 0.18, 'Extremely deep, avoid'),
('iiiiiiii-iiii-iiii-iiii-iiiiiiiiiiii', '33333333-3333-3333-3333-333333333333', 0.16, 'Reported to municipal corporation');

-- ================================================================
-- SEED ALERTS
-- ================================================================

INSERT INTO alerts (user_id, title, message, type, severity, hazard_id, metadata, action_url) VALUES
(
    '11111111-1111-1111-1111-111111111111',
    '⚠️ Pothole Ahead!',
    'Critical pothole detected 300m ahead on your route. Slow down and change lane if possible.',
    'hazard_proximity',
    'critical',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    '{"distance_m": 300, "eta_seconds": 18, "suggested_speed": 20}'::JSONB,
    'hazardnet://hazard/aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
),
(
    '22222222-2222-2222-2222-222222222222',
    '🔧 Maintenance Reminder',
    'Your cumulative damage score is 180. Schedule a suspension check soon.',
    'maintenance_due',
    'warning',
    NULL,
    '{"damage_score": 180, "recommended_service": "suspension_check"}'::JSONB,
    'hazardnet://maintenance/schedule'
),
(
    '33333333-3333-3333-3333-333333333333',
    '🏆 Achievement Unlocked',
    'You have reported 42 hazards! Thank you for making roads safer.',
    'achievement',
    'info',
    NULL,
    '{"achievement": "reporter_pro", "reports_count": 42}'::JSONB,
    'hazardnet://profile/achievements'
),
(
    '44444444-4444-4444-4444-444444444444',
    '🚧 Road Closure Alert',
    'Road closed 1.5km ahead due to construction. Alternative route suggested.',
    'hazard_proximity',
    'critical',
    'jjjjjjjj-jjjj-jjjj-jjjj-jjjjjjjjjjjj',
    '{"distance_m": 1500, "has_alternative": true}'::JSONB,
    'hazardnet://navigation/alternative'
),
(
    '55555555-5555-5555-5555-555555555555',
    '💡 Safety Tip',
    'Monsoon season alert: Reduce speed by 20% and maintain extra distance in wet conditions.',
    'safety_tip',
    'info',
    NULL,
    '{"season": "monsoon", "tips": ["reduce_speed", "increase_distance", "check_brakes"]}'::JSONB,
    NULL
);

-- ================================================================
-- SEED TRIP SESSIONS
-- ================================================================

INSERT INTO trip_sessions (id, user_id, start_time, end_time, start_location, end_location, distance_km, duration_minutes, hazards_detected, average_speed, max_speed, damage_score_increase) VALUES
(
    '11111111-aaaa-aaaa-aaaa-111111111111',
    '11111111-1111-1111-1111-111111111111',
    CURRENT_TIMESTAMP - INTERVAL '2 hours',
    CURRENT_TIMESTAMP - INTERVAL '1 hour 40 minutes',
    '{"lat": 28.6139, "lng": 77.2090, "address": "ITO, New Delhi"}'::JSONB,
    '{"lat": 28.5355, "lng": 77.3910, "address": "Noida Sector 62"}'::JSONB,
    18.5,
    20,
    3,
    55.5,
    75.2,
    15
),
(
    '22222222-bbbb-bbbb-bbbb-222222222222',
    '22222222-2222-2222-2222-222222222222',
    CURRENT_TIMESTAMP - INTERVAL '5 hours',
    CURRENT_TIMESTAMP - INTERVAL '4 hours 30 minutes',
    '{"lat": 19.0760, "lng": 72.8777, "address": "Gateway of India, Mumbai"}'::JSONB,
    '{"lat": 19.2183, "lng": 72.9781, "address": "Thane West"}'::JSONB,
    25.3,
    30,
    5,
    50.6,
    68.5,
    25
),
(
    '33333333-cccc-cccc-cccc-333333333333',
    '33333333-3333-3333-3333-333333333333',
    CURRENT_TIMESTAMP - INTERVAL '1 day',
    CURRENT_TIMESTAMP - INTERVAL '23 hours',
    '{"lat": 12.9716, "lng": 77.5946, "address": "MG Road, Bangalore"}'::JSONB,
    '{"lat": 13.0827, "lng": 80.2707, "address": "Chennai Airport"}'::JSONB,
    345.7,
    360,
    28,
    57.6,
    95.3,
    140
);

-- ================================================================
-- SEED SENSOR DATA (Sample impact detections)
-- ================================================================

INSERT INTO sensor_data (user_id, trip_id, timestamp, latitude, longitude, accelerometer, gyroscope, speed, heading, impact_detected, impact_severity) VALUES
(
    '11111111-1111-1111-1111-111111111111',
    '11111111-aaaa-aaaa-aaaa-111111111111',
    CURRENT_TIMESTAMP - INTERVAL '1 hour 50 minutes',
    28.6139,
    77.2090,
    '{"x": 0.05, "y": -9.81, "z": 2.45}'::JSONB,
    '{"x": 0.02, "y": -0.01, "z": 0.15}'::JSONB,
    45.2,
    135.5,
    TRUE,
    2.45
),
(
    '22222222-2222-2222-2222-222222222222',
    '22222222-bbbb-bbbb-bbbb-222222222222',
    CURRENT_TIMESTAMP - INTERVAL '4 hours 45 minutes',
    19.0760,
    72.8777,
    '{"x": 0.12, "y": -9.81, "z": 3.87}'::JSONB,
    '{"x": 0.05, "y": -0.03, "z": 0.22}'::JSONB,
    38.5,
    270.3,
    TRUE,
    3.87
),
(
    '33333333-3333-3333-3333-333333333333',
    '33333333-cccc-cccc-cccc-333333333333',
    CURRENT_TIMESTAMP - INTERVAL '1 day 2 hours',
    12.9716,
    77.5946,
    '{"x": -0.08, "y": -9.81, "z": 1.92}'::JSONB,
    '{"x": -0.02, "y": 0.01, "z": 0.08}'::JSONB,
    52.8,
    45.7,
    TRUE,
    1.92
);

-- ================================================================
-- SEED MAINTENANCE LOGS
-- ================================================================

INSERT INTO maintenance_logs (user_id, maintenance_date, damage_score_before, damage_score_after, maintenance_type, cost, notes, service_center) VALUES
(
    '11111111-1111-1111-1111-111111111111',
    CURRENT_TIMESTAMP - INTERVAL '30 days',
    450,
    0,
    'suspension',
    8500.00,
    'Full suspension overhaul, replaced shock absorbers',
    'AutoCare Service Center, Delhi'
),
(
    '22222222-2222-2222-2222-222222222222',
    CURRENT_TIMESTAMP - INTERVAL '45 days',
    320,
    0,
    'tires',
    12000.00,
    'Replaced all four tires due to damage from potholes',
    'Bridgestone Service, Mumbai'
),
(
    '33333333-3333-3333-3333-333333333333',
    CURRENT_TIMESTAMP - INTERVAL '15 days',
    680,
    0,
    'routine',
    5500.00,
    'Regular service and alignment check',
    'MRF Tire & Service, Pune'
);

-- ================================================================
-- SEED API KEYS (for testing integrations)
-- ================================================================

INSERT INTO api_keys (user_id, organization_name, api_key, rate_limit) VALUES
(
    '11111111-1111-1111-1111-111111111111',
    'HazardNet Development',
    'dev_test_key_1234567890abcdef',
    5000
),
(
    '55555555-5555-5555-5555-555555555555',
    'Fleet Management Corp',
    'prod_fleet_key_0987654321fedcba',
    10000
);

-- ================================================================
-- VERIFICATION QUERIES
-- ================================================================

-- Count records
SELECT 'Users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'Hazards', COUNT(*) FROM hazards
UNION ALL
SELECT 'Verifications', COUNT(*) FROM hazard_verifications
UNION ALL
SELECT 'Alerts', COUNT(*) FROM alerts
UNION ALL
SELECT 'Trip Sessions', COUNT(*) FROM trip_sessions
UNION ALL
SELECT 'Sensor Data', COUNT(*) FROM sensor_data
UNION ALL
SELECT 'Maintenance Logs', COUNT(*) FROM maintenance_logs
UNION ALL
SELECT 'API Keys', COUNT(*) FROM api_keys;

-- ================================================================
-- COMPLETION MESSAGE
-- ================================================================

SELECT '✅ Seed data inserted successfully!' AS status,
       '5 users, 10 hazards, 10 verifications, 5 alerts, 3 trips created' AS summary;
