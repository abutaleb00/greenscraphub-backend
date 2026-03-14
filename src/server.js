import dotenv from 'dotenv';
dotenv.config();

import http from 'http';
import { Server } from 'socket.io';
import os from 'os';

import app from './app.js';
import pool from './config/db.js';

const PORT = process.env.PORT || 4000;

const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  },
  pingTimeout: 60000,
});

/**
 * 3. Real-Time Tracking & Rider Management Logic
 */
io.on('connection', (socket) => {
  console.log(`🔌 New Connection: ${socket.id}`);

  // --- RIDER SPECIFIC LOGIC ---

  /**
   * 🛰️ Event: Rider joins their own private room and the global "active_riders" room
   */
  socket.on('register_rider', (riderId) => {
    socket.join(`rider_${riderId}`);
    socket.join('active_riders_map'); // For Admin/Agent Dashboard
    console.log(`🚛 Rider Registered: ${riderId} (Socket: ${socket.id})`);
  });

  /**
   * 🟢 Event: Rider Status Change (Online/Offline)
   * This broadcasts to the Admin dashboard immediately.
   */
  socket.on('rider_status_update', (data) => {
    // data: { riderId, is_online, location: { lat, lng } }
    const { riderId, is_online, location } = data;

    // Broadcast to Admin/Agent room
    io.to('active_riders_map').emit('rider_presence_changed', {
      riderId,
      is_online,
      location,
      last_updated: new Date()
    });

    console.log(`👤 Rider ${riderId} is now ${is_online ? 'ONLINE' : 'OFFLINE'}`);
  });

  /**
   * 📍 Event: Periodic Location Update
   * Updates the 'current_latitude' and 'current_longitude' for everyone watching
   */
  socket.on('update_location', (data) => {
    // data: { riderId, pickupId, latitude, longitude, heading }
    const { riderId, pickupId, latitude, longitude, heading } = data;

    const payload = {
      riderId,
      latitude,
      longitude,
      heading,
      timestamp: new Date()
    };

    // 1. Send to the specific customer assigned to this pickup
    if (pickupId) {
      io.to(`pickup_${pickupId}`).emit('location_changed', payload);
    }

    // 2. Send to Admin/Agent global map
    io.to('active_riders_map').emit('rider_moved', payload);
  });


  // --- CUSTOMER / PICKUP LOGIC ---

  socket.on('join_pickup', (pickupId) => {
    socket.join(`pickup_${pickupId}`);
    console.log(`📍 Customer joined room: pickup_${pickupId}`);
  });

  socket.on('pickup_status_changed', (data) => {
    const { pickupId, status } = data;
    io.to(`pickup_${pickupId}`).emit('status_updated', data);
    console.log(`📢 Status Update in room pickup_${pickupId}: ${status}`);
  });

  socket.on('disconnect', () => {
    console.log(`❌ Disconnected: ${socket.id}`);
  });
});

/**
 * 4. Global IO Access for REST Controllers
 */
app.set('io', io);

/**
 * 5. Network Utility
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
    await pool.query('SELECT 1');
    console.log('✅ MySQL Database Connected');

    const NETWORK_IP = getLocalIp();

    server.listen(PORT, '0.0.0.0', () => {
      console.log(`\n🚀 GreenScrapHub Backend Initialized:`);
      console.log(`🔗 API URL:     http://localhost:${PORT}/api/v1`);
      console.log(`📱 Network URL: http://${NETWORK_IP}:${PORT}/api/v1`);
      console.log(`🛰️ Socket.io:  Rider Tracking & Admin Map Enabled`);
      console.log(`___________________________________________________________\n`);
    });
  } catch (err) {
    console.error('❌ Server startup error:', err);
    process.exit(1);
  }
}

start();