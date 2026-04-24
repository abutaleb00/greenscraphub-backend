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
   * Join a private room and the global monitoring room
   */
  socket.on('register_rider', (riderId) => {
    socket.join(`rider_${riderId}`);
    socket.join('active_riders_map');
    console.log(`🚛 Rider Registered: ${riderId}`);
  });

  /**
   * 🟢 Event: Rider Status Change (Online/Offline)
   */
  socket.on('rider_status_update', async (data) => {
    const { riderId, is_online, location } = data;

    try {
      // FIX: Use 'id' instead of 'user_id' if your app is sending the Rider Table ID
      // We update both cases to be safe or you can standardize on Rider ID.
      await pool.query(
        'UPDATE riders SET is_online = ?, current_latitude = ?, current_longitude = ?, updated_at = NOW() WHERE id = ?',
        [is_online ? 1 : 0, location?.lat || null, location?.lng || null, riderId]
      );

      // Broadcast to Admin Dashboard
      io.to('active_riders_map').emit('rider_presence_changed', {
        riderId,
        is_online,
        location,
        last_updated: new Date()
      });

      console.log(`👤 Rider ${riderId} is now ${is_online ? 'ONLINE' : 'OFFLINE'}`);
    } catch (err) {
      console.error("❌ Error updating rider status in DB:", err);
    }
  });

  /**
   * 📍 Event: Periodic Location Update
   * Updates coordinates + Broadcasts to Customer & Admin
   */
  socket.on('update_location', async (data) => {
    const { riderId, pickupId, latitude, longitude, heading } = data;

    if (!latitude || !longitude) return;

    try {
      // 1. Database Sync (Using 'id' as the primary reference)
      await pool.query(
        'UPDATE riders SET current_latitude = ?, current_longitude = ?, updated_at = NOW() WHERE id = ?',
        [latitude, longitude, riderId]
      );

      const payload = {
        riderId,
        latitude: parseFloat(latitude),
        longitude: parseFloat(longitude),
        heading: heading || 0,
        timestamp: new Date()
      };

      // 2. Broadcast to Customer
      // Room name matches what the Customer joins: pickup_{id}
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

  /**
   * 📍 Event: Join Pickup Room
   * Customers join this to receive 'location_changed' events
   */
  socket.on('join_pickup', (pickupId) => {
    // Leave previous pickup rooms to prevent memory leaks/duplicate tracking
    Array.from(socket.rooms).forEach(room => {
      if (room.startsWith('pickup_')) socket.leave(room);
    });

    socket.join(`pickup_${pickupId}`);
    console.log(`📍 User ${socket.id} joined room: pickup_${pickupId}`);
  });

  /**
   * 📢 Event: Status Change
   * Notifies customer when status goes from 'accepted' to 'rider_on_way'
   */
  socket.on('pickup_status_changed', (data) => {
    const { pickupId, status } = data;
    io.to(`pickup_${pickupId}`).emit('status_updated', {
      pickupId,
      status,
      timestamp: new Date()
    });
    console.log(`📢 Status Update for pickup_${pickupId}: ${status}`);
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
    // Test DB Connection
    const [rows] = await pool.query('SELECT 1 + 1 AS result');
    console.log('✅ MySQL Database Connected');

    const NETWORK_IP = getLocalIp();

    server.listen(PORT, '0.0.0.0', () => {
      console.log(`\n🚀 GreenScrapHub Backend Initialized:`);
      console.log(`🔗 Local API:   http://localhost:${PORT}/api/v1`);
      console.log(`📱 Network API: http://${NETWORK_IP}:${PORT}/api/v1`);
      console.log(`🛰️ Socket.io:  Rider Tracking Rooms Enabled`);
      console.log(`___________________________________________________________\n`);
    });
  } catch (err) {
    console.error('❌ Server startup error:', err);
    process.exit(1);
  }
}

start();