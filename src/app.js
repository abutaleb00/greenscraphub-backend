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
 * Set to 'true' to trust all proxies. This is more reliable for 
 * cPanel/Nginx environments to ensure we get the real user IP.
 */
app.set('trust proxy', true);

// 2. Enhanced Security Middlewares
app.use(helmet({
  crossOriginResourcePolicy: false,
  crossOriginEmbedderPolicy: false,
}));

/**
 * 3. IP EXTRACTOR HELPER
 * This ensures rate limiters and logs always get the real client IP.
 */
const getClientIp = (req) => {
  return req.headers['x-forwarded-for']?.split(',')[0].trim() || req.ip || req.socket.remoteAddress;
};

/**
 * 4. TIERED RATE LIMITING CONFIGURATION
 */

// A. Passive Limiter: For background syncs (Push Tokens, Dashboard, Profile Me)
const passiveLimiter = rateLimit({
  windowMs: 10 * 60 * 1000,
  max: 1000,
  keyGenerator: getClientIp, // 🔥 Force real IP detection
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: "Background sync limit exceeded." }
});

// B. Auth Limiter: Stricter security for Login/Register/Forgot Password
const authLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 30,
  keyGenerator: getClientIp, // 🔥 Force real IP detection
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: "Too many authentication attempts. Please try again in an hour."
  }
});

// C. Global Limiter: General fallback for all other API routes
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 500,
  keyGenerator: getClientIp, // 🔥 Force real IP detection
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: "Too many requests from this IP, please try again after 15 minutes."
  }
});

/**
 * 5. Optimized CORS Configuration
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

// 6. Body Parsers & Logging
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Custom Morgan token to log the real IP
morgan.token('real-ip', (req) => getClientIp(req));
app.use(morgan(':real-ip :method :url :status :res[content-length] - :response-time ms'));

/**
 * 7. APPLY RATE LIMITERS STRATEGICALLY
 */
app.use('/api/v1/notifications/sync-token', passiveLimiter);
app.use('/api/v1/customers/dashboard', passiveLimiter);
app.use('/api/v1/auth/me', passiveLimiter);

app.use('/api/v1/auth/login', authLimiter);
app.use('/api/v1/auth/register', authLimiter);
app.use('/api/v1/auth/forgot-password', authLimiter);

app.use('/api/', globalLimiter);

// 8. Static Folders
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// 9. API routes
app.use('/api/v1', routes);

// Health root
app.get('/', (req, res) => {
  const realIp = getClientIp(req);

  res.json({
    success: true,
    message: 'GreenScrapHub API is Online',
    your_ip: realIp,
    proxy_ip: req.ip, // To see what Express thinks
    forwarded: req.headers['x-forwarded-for'], // To see the full chain
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'production'
  });
});

// 10. 404 + error handlers
app.use(notFound);
app.use(errorHandler);

export default app;