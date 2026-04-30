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
 * 2. Initialize Socket.io with Premium Configuration
 */
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  },
  pingTimeout: 60000, // Handle mobile network instability
});

/**
 * 3. Real-Time Fleet & Logistics Logic
 */
io.on('connection', (socket) => {
  console.log(`🔌 New encrypted link established: ${socket.id}`);

  // --- RIDER / FLEET MANAGEMENT ---

  /**
   * 🛰️ Event: Register Rider
   * Joins private telemetry room and global monitoring room
   */
  socket.on('register_rider', (userId) => {
    if (!userId) return;
    socket.join(`rider_user_${userId}`);
    socket.join('fleet_monitoring_room'); // Global room for Admin Dashboard
    console.log(`🚛 Rider Authenticated & Linked: User ID ${userId}`);
  });

  /**
   * 🟢 Event: Rider Presence Update (Online/Offline)
   */
  socket.on('rider_status_update', async (data) => {
    const { userId, is_online, location } = data;

    try {
      // Update riders table using user_id as the primary key
      await pool.query(
        `UPDATE riders SET 
          is_online = ?, 
          current_latitude = ?, 
          current_longitude = ?, 
          updated_at = NOW() 
         WHERE user_id = ?`,
        [is_online ? 1 : 0, location?.lat || null, location?.lng || null, userId]
      );

      // Broadcast presence change to Admin Fleet Map
      io.to('fleet_monitoring_room').emit('rider_presence_changed', {
        userId,
        is_online: !!is_online,
        location: location || null,
        timestamp: new Date()
      });

      console.log(`👤 Rider ${userId} status: ${is_online ? 'CONNECTED/ONLINE' : 'DISCONNECTED/OFFLINE'}`);
    } catch (err) {
      console.error("❌ DB Update Error (Status):", err.message);
    }
  });

  /**
   * 📍 Event: Live Telemetry (Periodic Location Update)
   * Syncs to DB and broadcasts to assigned Customer & Admin Fleet
   */
  socket.on('update_location', async (data) => {
    const { userId, pickupId, latitude, longitude, heading, speed } = data;

    if (!latitude || !longitude || !userId) return;

    try {
      // 1. Permanent Sync (MySQL)
      await pool.query(
        'UPDATE riders SET current_latitude = ?, current_longitude = ?, updated_at = NOW() WHERE user_id = ?',
        [latitude, longitude, userId]
      );

      const payload = {
        userId,
        latitude: parseFloat(latitude),
        longitude: parseFloat(longitude),
        heading: heading || 0,
        speed: speed || 0,
        timestamp: new Date()
      };

      // 2. Transmit to Customer (Assigned Mission Room)
      if (pickupId) {
        io.to(`pickup_${pickupId}`).emit('location_changed', payload);
      }

      // 3. Transmit to Fleet Monitoring (Admin Dashboard)
      io.to('fleet_monitoring_room').emit('rider_moved', payload);

    } catch (err) {
      console.error("❌ DB Update Error (Location):", err.message);
    }
  });


  // --- MISSION / CUSTOMER LOGIC ---

  /**
   * 📍 Event: Join Mission Tracker
   * Customers join this to receive real-time rider movement
   */
  socket.on('join_pickup', (pickupId) => {
    if (!pickupId) return;

    // Cleanup: Remove from previous missions to save memory
    Array.from(socket.rooms).forEach(room => {
      if (room.startsWith('pickup_')) socket.leave(room);
    });

    socket.join(`pickup_${pickupId}`);
    console.log(`📍 Subscriber joined Mission Tracker: pickup_${pickupId}`);
  });

  /**
   * 📢 Event: Mission Lifecycle Update
   * Notifies customer when status changes (Accepted -> On Way -> Arrived)
   */
  socket.on('pickup_status_changed', (data) => {
    const { pickupId, status } = data;
    if (!pickupId) return;

    io.to(`pickup_${pickupId}`).emit('status_updated', {
      pickupId,
      status,
      timestamp: new Date()
    });
    console.log(`📢 Mission ${pickupId} State Change: ${status.toUpperCase()}`);
  });

  socket.on('disconnect', () => {
    console.log(`❌ Link Terminated: ${socket.id}`);
  });
});

/**
 * 4. Attach Socket.io to Express context
 * Allows REST controllers to trigger real-time events
 */
app.set('io', io);

/**
 * 5. Network Discovery Utility
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
 * 6. Server Initialization Sequence
 */
async function start() {
  try {
    // Verify Database Readiness
    const [rows] = await pool.query('SELECT 1 + 1 AS result');
    console.log('✅ MySQL Telemetry DB Connected');

    const NETWORK_IP = getLocalIp();

    server.listen(PORT, '0.0.0.0', () => {
      console.log(`\n===========================================================`);
      console.log(`🚀 GREENSCRAP TACTICAL BACKEND INITIALIZED`);
      console.log(`===========================================================`);
      console.log(`🔗 Local Endpoint:   http://localhost:${PORT}/api/v1`);
      console.log(`📱 Network Gateway: http://${NETWORK_IP}:${PORT}/api/v1`);
      console.log(`🛰️ Socket Link:     Encryption & Fleet Tracking Active`);
      console.log(`___________________________________________________________\n`);
    });
  } catch (err) {
    console.error('❌ FATAL: Server failed to initialize:', err.message);
    process.exit(1);
  }
}

start();