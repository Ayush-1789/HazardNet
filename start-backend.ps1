# HazardNet Backend - Quick Start Commands

# ========================================
# STEP 1: Check Backend Files
# ========================================
Write-Host "`n=== Backend Files ===" -ForegroundColor Cyan
Get-ChildItem backend -Name

# ========================================
# STEP 2: Open .env for Configuration
# ========================================
Write-Host "`n=== Configure Database ===" -ForegroundColor Yellow
Write-Host "Opening .env file..." -ForegroundColor White
Write-Host "Please update DATABASE_URL with your Neon connection string`n" -ForegroundColor Green

# Uncomment to auto-open .env
# notepad backend\.env

# ========================================
# STEP 3: Start Backend Server
# ========================================
Write-Host "=== After configuring .env, run: ===" -ForegroundColor Yellow
Write-Host "cd backend" -ForegroundColor Green
Write-Host "npm run dev" -ForegroundColor Green
Write-Host ""

# To automatically start server (after .env is configured):
# Set-Location backend
# npm run dev
