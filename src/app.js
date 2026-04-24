import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import helmet from 'helmet';
import path from 'path';
import { fileURLToPath } from 'url';
import rateLimit from 'express-rate-limit';
import routes from './routes/index.js';
import { notFound, errorHandler } from './middlewares/errorHandler.js';

// Setup __dirname for ESM
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();

/**
 * 1. PROXY CONFIGURATION
 * Set to 1 to trust the first proxy (cPanel/Nginx/Cloudflare) 
 * to get the correct User IP for rate limiting.
 */
app.set('trust proxy', 1);

// 2. Enhanced Security Middlewares
app.use(helmet({
  crossOriginResourcePolicy: false,
  crossOriginEmbedderPolicy: false,
}));

/**
 * 3. TIERED RATE LIMITING CONFIGURATION
 */

// A. Passive Limiter: For background syncs (Push Tokens, Dashboard, Profile Me)
// These are called automatically by the app, so we allow a much higher limit.
const passiveLimiter = rateLimit({
  windowMs: 10 * 60 * 1000, // 10 minutes
  max: 1000, // Allow 1000 hits per 10 mins (prevents Dev Fast Refresh blocks)
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: "Background sync limit exceeded." }
});

// B. Auth Limiter: Stricter security for Login/Register/Forgot Password
const authLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 30, // Increased to 30 for easier testing/usage
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: "Too many authentication attempts. Please try again in an hour."
  }
});

// C. Global Limiter: General fallback for all other API routes
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 500, // Increased from 100 to 500 for a smoother user experience
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: "Too many requests from this IP, please try again after 15 minutes."
  }
});

/**
 * 4. Optimized CORS Configuration
 */
const allowedOrigins = [
  'http://localhost:3000',
  'http://localhost:3001',
  'https://greenscrap-web.vercel.app',
  'https://webapp.prosfata.space',
  'https://www.smartscrapbd.store',
];

app.use(
  cors({
    origin: function (origin, callback) {
      // Allow mobile apps (no origin) and development
      if (!origin || process.env.NODE_ENV === 'development') return callback(null, true);
      if (allowedOrigins.indexOf(origin) !== -1) {
        callback(null, true);
      } else {
        callback(new Error('Not allowed by CORS'));
      }
    },
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
    credentials: true,
  })
);

// 5. Body Parsers & Logging
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

app.use(morgan(':remote-addr :method :url :status :res[content-length] - :response-time ms'));

/**
 * 6. APPLY RATE LIMITERS STRATEGICALLY
 * Order matters! Specific routes must come before general ones.
 */

// Tier 1: Background Passive Routes (Dashboard, Tokens)
app.use('/api/v1/notifications/sync-token', passiveLimiter);
app.use('/api/v1/customers/dashboard', passiveLimiter);
app.use('/api/v1/auth/me', passiveLimiter);

// Tier 2: Strict Auth Routes
app.use('/api/v1/auth/login', authLimiter);
app.use('/api/v1/auth/register', authLimiter);
app.use('/api/v1/auth/forgot-password', authLimiter);

// Tier 3: Global Catch-all for API
app.use('/api/', globalLimiter);

// 7. Static Folders
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// 8. API routes
app.use('/api/v1', routes);

// Health root
app.get('/', (req, res) => {
  const publicIp = req.ip || req.headers['x-forwarded-for'] || req.socket.remoteAddress;

  res.json({
    success: true,
    message: 'GreenScrapHub API is Online',
    your_ip: publicIp,
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'production'
  });
});

// 9. 404 + error handlers
app.use(notFound);
app.use(errorHandler);

export default app;