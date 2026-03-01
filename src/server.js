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
 * Configured with CORS to allow connections from your Mobile App.
 */
const io = new Server(server, {
  cors: {
    origin: "*", // Allow all origins for development
    methods: ["GET", "POST"]
  }
});

/**
 * 3. Real-Time Tracking Logic
 * Manages "Rooms" so only customers tracking a specific pickup see the rider.
 */
io.on('connection', (socket) => {
  console.log(`🔌 New Connection: ${socket.id}`);

  // Customer joins a room based on their Pickup ID
  socket.on('join_pickup', (pickupId) => {
    socket.join(`pickup_${pickupId}`);
    console.log(`📍 Customer joined tracking room: pickup_${pickupId}`);
  });

  // Rider emits their live coordinates
  socket.on('update_location', (data) => {
    // Expected data: { pickupId, latitude, longitude, heading }
    const { pickupId, latitude, longitude, heading } = data;

    // Broadcast only to the customer in that specific pickup room
    io.to(`pickup_${pickupId}`).emit('location_changed', {
      latitude,
      longitude,
      heading,
      timestamp: new Date()
    });
  });

  socket.on('disconnect', () => {
    console.log(`❌ Disconnected: ${socket.id}`);
  });
});

/**
 * 4. Network Utility
 * Auto-detects your PC's IP to help connect your physical phone.
 */
const getLocalIp = () => {
  const interfaces = os.networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name] || []) {
      if (iface.family === 'IPv4' && !iface.internal) return iface.address;
    }
  }
  return 'localhost';
};

/**
 * 5. Startup Sequence
 */
async function start() {
  try {
    // Verify Database Connection
    await pool.query('SELECT 1');
    console.log('✅ MySQL Database Connected');

    const NETWORK_IP = getLocalIp();

    // Start the Server (Use 'server.listen' instead of 'app.listen')
    server.listen(PORT, '0.0.0.0', () => {
      console.log(`\n🚀 GreenScrapHub Real-Time Server Running:`);
      console.log(`🔗 Local:   http://localhost:${PORT}`);
      console.log(`📱 Network: http://${NETWORK_IP}:${PORT}\n`);
      console.log(`🛰️ Socket.io: Enabled for Live Rider Tracking`);
      console.log(`👉 Use the Network URL in your React Native src/api/client.js`);
    });
  } catch (err) {
    console.error('❌ Server startup error:', err);
    process.exit(1);
  }
}

start();