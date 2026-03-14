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
 */
const server = http.createServer(app);

/**
 * 2. Initialize Socket.io
 */
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
   * 🛰️ Event: Rider Registration
   */
  socket.on('register_rider', (riderId) => {
    socket.join(`rider_${riderId}`);
    socket.join('active_riders_map');
    console.log(`🚛 Rider Registered: ${riderId}`);
  });

  /**
   * 🟢 Event: Rider Status Change (Online/Offline)
   * Syncs with Database + Broadcasts to Admin
   */
  socket.on('rider_status_update', async (data) => {
    const { riderId, is_online, location } = data;

    try {
      // Sync to Database
      await pool.query(
        'UPDATE riders SET is_online = ?, current_latitude = ?, current_longitude = ?, updated_at = NOW() WHERE user_id = ?',
        [is_online ? 1 : 0, location?.lat || null, location?.lng || null, riderId]
      );

      // Broadcast to Admin Dashboard
      io.to('active_riders_map').emit('rider_presence_changed', {
        riderId,
        is_online,
        location,
        last_updated: new Date()
      });

      console.log(`👤 Rider ${riderId} Database & Socket updated to ${is_online ? 'ONLINE' : 'OFFLINE'}`);
    } catch (err) {
      console.error("❌ Error updating rider status in DB:", err);
    }
  });

  /**
   * 📍 Event: Periodic Location Update
   * Updates MySQL Coordinates + Broadcasts to Customer & Admin
   */
  socket.on('update_location', async (data) => {
    const { riderId, pickupId, latitude, longitude, heading } = data;

    try {
      // 1. Silent Database Sync (Keep records fresh)
      // We do this every update to ensure 'current_latitude' is always accurate
      await pool.query(
        'UPDATE riders SET current_latitude = ?, current_longitude = ?, updated_at = NOW() WHERE user_id = ?',
        [latitude, longitude, riderId]
      );

      const payload = {
        riderId,
        latitude,
        longitude,
        heading,
        timestamp: new Date()
      };

      // 2. Broadcast to specific customer (if on a trip)
      if (pickupId) {
        io.to(`pickup_${pickupId}`).emit('location_changed', payload);
      }

      // 3. Broadcast to global Admin map
      io.to('active_riders_map').emit('rider_moved', payload);

    } catch (err) {
      console.error("❌ Error syncing location to DB:", err);
    }
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
 * 4. Global IO Access
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
      console.log(`🛰️ Socket.io:  Rider DB Sync & Live Map Enabled`);
      console.log(`___________________________________________________________\n`);
    });
  } catch (err) {
    console.error('❌ Server startup error:', err);
    process.exit(1);
  }
}

start();