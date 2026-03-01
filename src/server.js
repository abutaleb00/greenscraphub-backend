import dotenv from 'dotenv';
dotenv.config();

import http from 'http';
import { Server } from 'socket.io';
import os from 'os';

import app from './app.js';
import pool from './config/db.js';

const PORT = process.env.PORT || 4000;

/**
 * 1. Create HTTP Server 
 * Socket.io requires a raw HTTP server to attach its listeners.
 */
const server = http.createServer(app);

/**
 * 2. Initialize Socket.io
 * Configured with CORS and standardized for Mobile + Web.
 */
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  },
  pingTimeout: 60000, // Handle mobile sleep/wake cycles better
});

/**
 * 3. Real-Time Tracking & Notification Logic
 */
io.on('connection', (socket) => {
  console.log(`🔌 New Connection: ${socket.id}`);

  // Customer/Rider joins a room based on the Pickup ID
  socket.on('join_pickup', (pickupId) => {
    socket.join(`pickup_${pickupId}`);
    console.log(`📍 User joined room: pickup_${pickupId}`);
  });

  // Rider emits live coordinates
  socket.on('update_location', (data) => {
    // data: { pickupId, latitude, longitude, heading }
    const { pickupId, latitude, longitude, heading } = data;

    // Broadcast only to the customer in that specific pickup room
    io.to(`pickup_${pickupId}`).emit('location_changed', {
      latitude,
      longitude,
      heading,
      timestamp: new Date()
    });
  });

  /**
   * ✨ NEW: Status Update Broadcast
   * Used when a pickup is marked 'completed' or 'arrived'.
   * This triggers the "Points Earned" modal on the customer's phone.
   */
  socket.on('pickup_status_changed', (data) => {
    // data: { pickupId, status, pointsEarned, netTotal }
    const { pickupId, status } = data;

    io.to(`pickup_${pickupId}`).emit('status_updated', data);
    console.log(`📢 Status Update in room pickup_${pickupId}: ${status}`);
  });

  socket.on('disconnect', () => {
    console.log(`❌ Disconnected: ${socket.id}`);
  });
});

/**
 * 4. Global IO Access
 * Attach the IO instance to the 'app' so we can use it inside 
 * our Controllers (like pickupController.js) via 'req.app.get("io")'.
 */
app.set('io', io);

/**
 * 5. Network Utility
 * Auto-detects your PC's IP to help connect your physical phone.
 */
const getLocalIp = () => {
  const interfaces = os.networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    for (const iface of (interfaces[name] || [])) {
      if (iface.family === 'IPv4' && !iface.internal) return iface.address;
    }
  }
  return 'localhost';
};

/**
 * 6. Startup Sequence
 */
async function start() {
  try {
    // Verify Database Connection
    await pool.query('SELECT 1');
    console.log('✅ MySQL Database Connected');

    const NETWORK_IP = getLocalIp();

    // Start the Server
    server.listen(PORT, '0.0.0.0', () => {
      console.log(`\n🚀 GreenScrapHub Backend Initialized:`);
      console.log(`🔗 API URL:     http://localhost:${PORT}/api/v1`);
      console.log(`📱 Network URL: http://${NETWORK_IP}:${PORT}/api/v1`);
      console.log(`🛰️ Socket.io:  Enabled for Live Rider Tracking & Points Alerts`);
      console.log(`___________________________________________________________\n`);
    });
  } catch (err) {
    console.error('❌ Server startup error:', err);
    process.exit(1);
  }
}

start();