# 🗄️ HazardNet Database Architecture

## 📊 Visual Schema Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         HAZARDNET DATABASE                          │
│                      (Neon PostgreSQL 14+)                          │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────────┐
│     USERS        │
├──────────────────┤
│ • id (PK)        │◄────────┐
│ • email          │         │
│ • display_name   │         │
│ • vehicle_type   │         │
│ • cumulative_    │         │
│   damage_score   │         │
│ • driver_profile │         │
│   (JSONB)        │         │
│ • preferences    │         │
│   (JSONB)        │         │
│ • is_premium     │         │
│ • total_hazards_ │         │
│   reported       │         │
└──────────────────┘         │
         │                   │
         │ reported_by       │ user_id
         ▼                   │
┌──────────────────┐         │
│    HAZARDS       │         │
├──────────────────┤         │
│ • id (PK)        │◄────┐   │
│ • type           │     │   │
│ • latitude       │     │   │
│ • longitude      │     │   │
│ • severity       │     │   │
│ • confidence     │     │   │
│ • detected_at    │     │   │
│ • image_url      │     │   │
│ • verification_  │     │   │
│   count          │     │   │
│ • is_verified    │     │   │
│ • metadata       │     │   │
│   (JSONB)        │     │   │
│ • depth          │     │   │
│ • reported_by    │─────┘   │
│   (FK → users)   │         │
└──────────────────┘         │
         │                   │
         │ hazard_id         │
         ▼                   │
┌─────────────────────┐      │
│ HAZARD_             │      │
│ VERIFICATIONS       │      │
├─────────────────────┤      │
│ • id (PK)           │      │
│ • hazard_id (FK)    │      │
│ • user_id (FK)      │──────┘
│ • verified_at       │
│ • confidence_boost  │
│ • notes             │
└─────────────────────┘
         
┌──────────────────┐
│     ALERTS       │
├──────────────────┤
│ • id (PK)        │
│ • user_id (FK)   │──────┐
│ • title          │      │
│ • message        │      │
│ • type           │      │
│ • severity       │      │
│ • timestamp      │      │
│ • is_read        │      │
│ • hazard_id (FK) │──┐   │
│ • metadata       │  │   │
│   (JSONB)        │  │   │
│ • action_url     │  │   │
└──────────────────┘  │   │
                      │   │
                      │   │
┌──────────────────┐  │   │
│  TRIP_SESSIONS   │  │   │
├──────────────────┤  │   │
│ • id (PK)        │  │   │
│ • user_id (FK)   │──┘   │
│ • start_time     │      │
│ • end_time       │      │
│ • start_location │      │
│   (JSONB)        │      │
│ • end_location   │      │
│   (JSONB)        │      │
│ • distance_km    │      │
│ • duration_min   │      │
│ • hazards_       │      │
│   detected       │      │
│ • damage_score_  │      │
│   increase       │      │
└──────────────────┘      │
         │                │
         │ trip_id        │
         ▼                │
┌──────────────────┐      │
│  SENSOR_DATA     │      │
├──────────────────┤      │
│ • id (PK)        │      │
│ • user_id (FK)   │──────┤
│ • trip_id (FK)   │      │
│ • timestamp      │      │
│ • latitude       │      │
│ • longitude      │      │
│ • accelerometer  │      │
│   (JSONB)        │      │
│ • gyroscope      │      │
│   (JSONB)        │      │
│ • speed          │      │
│ • impact_        │      │
│   detected       │      │
│ • impact_        │      │
│   severity       │      │
└──────────────────┘      │
                          │
┌──────────────────┐      │
│ MAINTENANCE_LOGS │      │
├──────────────────┤      │
│ • id (PK)        │      │
│ • user_id (FK)   │──────┘
│ • maintenance_   │
│   date           │
│ • damage_score_  │
│   before         │
│ • damage_score_  │
│   after          │
│ • maintenance_   │
│   type           │
│ • cost           │
│ • notes          │
│ • service_center │
└──────────────────┘

┌──────────────────┐
│    API_KEYS      │
├──────────────────┤
│ • id (PK)        │
│ • user_id (FK)   │──────┐
│ • organization_  │      │
│   name           │      │
│ • api_key        │      │
│ • is_active      │      │
│ • rate_limit     │      │
│ • created_at     │      │
│ • expires_at     │      │
└──────────────────┘      │
                          │
                          └─────────────────┐
                                            │
                    ┌───────────────────────┘
                    │
                    ▼
          ┌──────────────────┐
          │  USERS (again)   │
          └──────────────────┘
```

---

## 🔑 Table Relationships Summary

```
users (1) ──── (many) hazards
users (1) ──── (many) hazard_verifications
users (1) ──── (many) alerts
users (1) ──── (many) trip_sessions
users (1) ──── (many) sensor_data
users (1) ──── (many) maintenance_logs
users (1) ──── (many) api_keys

hazards (1) ──── (many) hazard_verifications
hazards (1) ──── (many) alerts

trip_sessions (1) ──── (many) sensor_data
```

---

## 📈 Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    HAZARDNET DATA FLOW                      │
└─────────────────────────────────────────────────────────────┘

1. USER TRIP FLOW
─────────────────
   [User Opens App]
          │
          ▼
   [Start Trip Session] ──► INSERT INTO trip_sessions
          │
          ▼
   [Camera + Sensors Active]
          │
          ├──► [Accelerometer Data] ──► INSERT INTO sensor_data
          │
          └──► [Camera Detection]
                     │
                     ▼
              [ML Model Processing]
                     │
                     ▼
              [Hazard Detected?]
                     │
                ┌────┴────┐
                │  YES    │  NO (Continue monitoring)
                │         │
                ▼         ▼
    INSERT INTO hazards   [Keep recording]
         │
         ▼
    [Auto-create Alert] ──► INSERT INTO alerts
         │
         ▼
    [Notify Nearby Users] ──► SELECT users WHERE distance < radius


2. HAZARD VERIFICATION FLOW
────────────────────────────
   [User Sees Hazard]
          │
          ▼
   [Confirms: "Yes, I see it too"]
          │
          ▼
   INSERT INTO hazard_verifications
          │
          ▼
   [TRIGGER: update_hazard_verification_count]
          │
          ▼
   UPDATE hazards SET verification_count++
          │
          ▼
   [Check: verification_count >= 3?]
          │
       ┌──┴──┐
       │ YES │  NO (Wait for more)
       │     │
       ▼     ▼
   UPDATE hazards
   SET is_verified = TRUE


3. DAMAGE SCORING FLOW
───────────────────────
   [Trip in Progress]
          │
          ▼
   [Accelerometer Impact Detected]
          │
          ▼
   INSERT INTO sensor_data
   (impact_detected = TRUE)
          │
          ▼
   [Calculate Impact Severity]
          │
          ▼
   UPDATE trip_sessions
   SET damage_score_increase++
          │
          ▼
   [Trip Ends]
          │
          ▼
   UPDATE users
   SET cumulative_damage_score += trip.damage_score_increase
          │
          ▼
   [Check: cumulative_damage_score > threshold?]
          │
       ┌──┴──┐
       │ YES │  NO
       │     │
       ▼     ▼
   INSERT INTO alerts
   (type = 'maintenance_due')


4. MAINTENANCE RESET FLOW
──────────────────────────
   [User Goes for Service]
          │
          ▼
   [Records Maintenance]
          │
          ▼
   INSERT INTO maintenance_logs
   (damage_score_before = current_score)
          │
          ▼
   UPDATE users
   SET cumulative_damage_score = 0,
       last_maintenance_check = NOW()
```

---

## 🎯 Key Database Operations

### CREATE (Insert New Records)
```sql
-- 1. New User Registration
INSERT INTO users (email, display_name, vehicle_type) 
VALUES ('user@example.com', 'John Doe', 'car');

-- 2. Hazard Detection
INSERT INTO hazards (type, latitude, longitude, severity, confidence, reported_by)
VALUES ('pothole', 28.6139, 77.2090, 'high', 0.92, 'user-uuid');

-- 3. Start Trip
INSERT INTO trip_sessions (user_id, start_location)
VALUES ('user-uuid', '{"lat": 28.6, "lng": 77.2}');
```

### READ (Query Data)
```sql
-- 1. Get Nearby Hazards (Within 500m)
SELECT * FROM hazards 
WHERE calculate_distance(user_lat, user_lng, latitude, longitude) <= 0.5
  AND is_active = TRUE;

-- 2. User's Unread Alerts
SELECT * FROM alerts 
WHERE user_id = 'user-uuid' AND is_read = FALSE
ORDER BY timestamp DESC;

-- 3. Trip History
SELECT * FROM trip_sessions 
WHERE user_id = 'user-uuid'
ORDER BY start_time DESC
LIMIT 10;
```

### UPDATE (Modify Records)
```sql
-- 1. Mark Alert as Read
UPDATE alerts 
SET is_read = TRUE 
WHERE id = 'alert-uuid';

-- 2. Verify Hazard
INSERT INTO hazard_verifications (hazard_id, user_id)
VALUES ('hazard-uuid', 'user-uuid');
-- Trigger auto-updates verification_count

-- 3. End Trip
UPDATE trip_sessions
SET end_time = NOW(),
    end_location = '{"lat": 19.0, "lng": 72.8}',
    distance_km = 25.5,
    duration_minutes = 45
WHERE id = 'trip-uuid';
```

### DELETE (Soft Delete)
```sql
-- 1. Deactivate Hazard (Soft Delete)
UPDATE hazards 
SET is_active = FALSE, 
    resolved_at = NOW()
WHERE id = 'hazard-uuid';

-- 2. Expire Old Alerts
DELETE FROM alerts
WHERE expires_at < NOW();
```

---

## 🚀 Performance Optimization

### Indexes Created
```sql
-- Geospatial queries
CREATE INDEX idx_hazards_location ON hazards(latitude, longitude);

-- Type filtering
CREATE INDEX idx_hazards_type ON hazards(type);

-- Time-based queries
CREATE INDEX idx_hazards_detected_at ON hazards(detected_at DESC);

-- User-specific queries
CREATE INDEX idx_alerts_user ON alerts(user_id);
CREATE INDEX idx_trips_user ON trip_sessions(user_id);

-- Composite index for complex queries
CREATE INDEX idx_hazards_location_type 
ON hazards(latitude, longitude, type);
```

### Expected Query Performance
- **Nearby Hazards (500m radius):** < 50ms (with 100K records)
- **User Alerts:** < 10ms (indexed by user_id)
- **Trip History:** < 20ms (indexed by user_id + timestamp)
- **Hazard Verification Count:** Instant (trigger-based)

---

## 💾 Storage Estimates

### Small Scale (1,000 users, 1 month)
- Users: ~100 KB
- Hazards: ~1 MB
- Alerts: ~500 KB
- Trip Sessions: ~2 MB
- Sensor Data: ~50 MB (high frequency recording)
- **Total:** ~54 MB

### Medium Scale (10,000 users, 6 months)
- Users: ~1 MB
- Hazards: ~50 MB
- Alerts: ~20 MB
- Trip Sessions: ~100 MB
- Sensor Data: ~3 GB
- **Total:** ~3.2 GB

### Large Scale (100,000 users, 1 year)
- Users: ~10 MB
- Hazards: ~500 MB
- Alerts: ~200 MB
- Trip Sessions: ~1 GB
- Sensor Data: ~30 GB (consider time-series DB)
- **Total:** ~32 GB

**Note:** Sensor data grows fastest. Consider archiving or time-series DB (TimescaleDB) for production.

---

## 🔒 Security Measures Implemented

1. **SSL/TLS Encryption** - All connections encrypted
2. **Parameterized Queries** - Prevents SQL injection
3. **Password Hashing** - Users table has `password_hash` (use bcrypt)
4. **UUID Primary Keys** - Harder to enumerate records
5. **Soft Deletes** - `is_active` flag preserves data
6. **JSONB Validation** - Constrained metadata fields
7. **Foreign Key Constraints** - Maintains referential integrity
8. **Check Constraints** - Validates severity, coordinates, etc.

---

## 📊 Monitoring Queries

```sql
-- 1. Database Health Check
SELECT 
    'Users' as table, COUNT(*) as count FROM users
UNION ALL
SELECT 'Hazards', COUNT(*) FROM hazards
UNION ALL
SELECT 'Active Hazards', COUNT(*) FROM hazards WHERE is_active = TRUE;

-- 2. Top Contributors
SELECT display_name, total_hazards_reported, verified_reports
FROM users
ORDER BY total_hazards_reported DESC
LIMIT 5;

-- 3. Hazard Type Distribution
SELECT type, COUNT(*) as count, AVG(confidence) as avg_confidence
FROM hazards
WHERE is_active = TRUE
GROUP BY type
ORDER BY count DESC;

-- 4. Recent Activity
SELECT 
    DATE(detected_at) as date,
    COUNT(*) as hazards_reported
FROM hazards
WHERE detected_at > NOW() - INTERVAL '7 days'
GROUP BY DATE(detected_at)
ORDER BY date DESC;
```

---

**🎉 Your database is production-ready! Start building the backend API now.**

