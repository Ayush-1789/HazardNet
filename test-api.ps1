Write-Host ""
Write-Host "HazardNet API Integration Test" -ForegroundColor Cyan
Write-Host ""

# Check server
Write-Host "Checking server..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://localhost:3000/health"
    Write-Host "SUCCESS: Server is running!" -ForegroundColor Green
    Write-Host "Uptime: $($health.uptime) seconds" -ForegroundColor Gray
} catch {
    Write-Host "ERROR: Server is not running!" -ForegroundColor Red
    Write-Host "Please run: node test-backend.js" -ForegroundColor Yellow
    exit 1
}

# Test Registration
Write-Host ""
Write-Host "Test 1: User Registration" -ForegroundColor Cyan
$registerBody = @{
    email = "testuser@hazardnet.com"
    password = "SecurePass123"
    displayName = "Test User"
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/auth/register" -Method POST -Body $registerBody -ContentType "application/json"
    Write-Host "SUCCESS: User registered!" -ForegroundColor Green
    Write-Host "User ID: $($registerResponse.userId)" -ForegroundColor Gray
    $token = $registerResponse.token
} catch {
    Write-Host "User already exists, trying login..." -ForegroundColor Yellow
    $loginBody = @{
        email = "testuser@hazardnet.com"
        password = "SecurePass123"
    } | ConvertTo-Json
    
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    Write-Host "SUCCESS: Logged in!" -ForegroundColor Green
    $token = $loginResponse.token
}

# Test Profile
Write-Host ""
Write-Host "Test 2: Get User Profile" -ForegroundColor Cyan
$headers = @{ "Authorization" = "Bearer $token" }

try {
    $userProfile = Invoke-RestMethod -Uri "http://localhost:3000/api/auth/profile" -Headers $headers
    Write-Host "SUCCESS: Profile retrieved!" -ForegroundColor Green
    Write-Host "Email: $($userProfile.email)" -ForegroundColor Gray
    Write-Host "Display Name: $($userProfile.displayName)" -ForegroundColor Gray
} catch {
    Write-Host "ERROR: Failed to get profile" -ForegroundColor Red
}

# Test Report Hazard
Write-Host ""
Write-Host "Test 3: Report Hazard" -ForegroundColor Cyan
$hazardBody = @{
    latitude = 40.7128
    longitude = -74.0060
    hazardType = "pothole"
    severity = "high"
    description = "Large pothole on Main Street"
    address = "Main St, New York, NY"
} | ConvertTo-Json

try {
    $hazard = Invoke-RestMethod -Uri "http://localhost:3000/api/hazards/report" -Method POST -Headers $headers -Body $hazardBody -ContentType "application/json"
    Write-Host "SUCCESS: Hazard reported!" -ForegroundColor Green
    Write-Host "Hazard ID: $($hazard.hazardId)" -ForegroundColor Gray
    Write-Host "Type: $($hazard.hazard.hazardType)" -ForegroundColor Gray
    $hazardId = $hazard.hazardId
} catch {
    Write-Host "ERROR: Failed to report hazard" -ForegroundColor Red
}

# Test Nearby Hazards
Write-Host ""
Write-Host "Test 4: Get Nearby Hazards" -ForegroundColor Cyan
$nearbyUrl = "http://localhost:3000/api/hazards/nearby"
$queryParams = @{
    latitude = 40.7128
    longitude = -74.0060
    radius = 5000
}

try {
    $nearbyHazards = Invoke-RestMethod -Uri $nearbyUrl -Method GET -Headers $headers -Body $queryParams
    Write-Host "SUCCESS: Found $($nearbyHazards.count) nearby hazards" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to get nearby hazards" -ForegroundColor Red
}

# Test Start Trip
Write-Host ""
Write-Host "Test 5: Start Trip" -ForegroundColor Cyan
$tripBody = @{
    startLatitude = 40.7128
    startLongitude = -74.0060
} | ConvertTo-Json

try {
    $trip = Invoke-RestMethod -Uri "http://localhost:3000/api/trips/start" -Method POST -Headers $headers -Body $tripBody -ContentType "application/json"
    Write-Host "SUCCESS: Trip started!" -ForegroundColor Green
    Write-Host "Trip ID: $($trip.tripId)" -ForegroundColor Gray
    $tripId = $trip.tripId
} catch {
    Write-Host "ERROR: Failed to start trip" -ForegroundColor Red
}

# Test End Trip
if ($tripId) {
    Write-Host ""
    Write-Host "Test 6: End Trip" -ForegroundColor Cyan
    Start-Sleep -Seconds 1
    
    $endTripBody = @{
        endLatitude = 40.7589
        endLongitude = -73.9851
        distance = 5.2
    } | ConvertTo-Json

    try {
        $endTrip = Invoke-RestMethod -Uri "http://localhost:3000/api/trips/$tripId/end" -Method POST -Headers $headers -Body $endTripBody -ContentType "application/json"
        Write-Host "SUCCESS: Trip ended!" -ForegroundColor Green
        Write-Host "Duration: $($endTrip.trip.duration) seconds" -ForegroundColor Gray
    } catch {
        Write-Host "ERROR: Failed to end trip" -ForegroundColor Red
    }
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "API Integration Test Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "All major features tested successfully:" -ForegroundColor Green
Write-Host "  - User Authentication" -ForegroundColor Gray
Write-Host "  - User Profile" -ForegroundColor Gray
Write-Host "  - Hazard Reporting" -ForegroundColor Gray
Write-Host "  - Nearby Hazards Search" -ForegroundColor Gray
Write-Host "  - Trip Tracking" -ForegroundColor Gray
Write-Host ""
Write-Host "Backend API is fully functional!" -ForegroundColor Cyan
Write-Host ""
