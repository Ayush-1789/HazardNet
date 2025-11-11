require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const { pool } = require('./db');

const app = express();
const PORT = process.env.PORT || 3000;
const HOST = '0.0.0.0'; // Listen on all network interfaces

// Middleware
app.use(helmet());
app.use(cors({
  origin: '*', // Allow all origins for development
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json());

// Serve uploaded files
app.use('/uploads', express.static('uploads'));

// Test database connection
pool.query('SELECT NOW()', (err, res) => {
  if (err) {
    console.error('❌ Database connection error:', err);
  }
});

// Root endpoint for EB health check
app.get('/', (req, res) => {
  res.json({ 
    status: 'ok', 
    message: 'HazardNet API Server',
    timestamp: new Date().toISOString()
  });
});

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// API Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/hazards', require('./routes/hazards'));
app.use('/api/alerts', require('./routes/alerts'));
app.use('/api/trips', require('./routes/trips'));
app.use('/api/sensor-data', require('./routes/sensor-data'));
app.use('/api/gamification', require('./routes/gamification'));
app.use('/api/emergency', require('./routes/emergency'));
app.use('/api/authority', require('./routes/authority'));

// Error handler
app.use((err, req, res, next) => {
  console.error('Error:', err.stack);
  res.status(err.status || 500).json({ 
    error: err.message || 'Something went wrong!',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

const server = app.listen(PORT, HOST, () => {
  const os = require('os');
  const networkInterfaces = os.networkInterfaces();
  const networkIP = Object.values(networkInterfaces)
    .flat()
    .find(info => info.family === 'IPv4' && !info.internal)?.address || 'Unknown';
  
  console.log(`🚀 HazardNet API Server running on:`);
  console.log(`   Local:   http://localhost:${PORT}`);
  console.log(`   Network: http://${networkIP}:${PORT}`);
  console.log(`📊 Health check: http://${networkIP}:${PORT}/health`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`📱 Mobile app can now connect!`);
});

// Handle server errors
server.on('error', (error) => {
  if (error.code === 'EADDRINUSE') {
    console.error(`❌ Port ${PORT} is already in use`);
  } else {
    console.error('❌ Server error:', error);
  }
  process.exit(1);
});

// Handle uncaught errors
process.on('unhandledRejection', (reason, promise) => {
  console.error('❌ Unhandled Rejection at:', promise, 'reason:', reason);
});

process.on('uncaughtException', (error) => {
  console.error('❌ Uncaught Exception:', error);
  process.exit(1);
});
