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
 * Crucial for Nginx/VPS to pass the real IP to Express
 */
app.set('trust proxy', 1);

// 2. Enhanced Security Middlewares
app.use(helmet({
  crossOriginResourcePolicy: false,
  crossOriginEmbedderPolicy: false,
}));

/**
 * 3. TIERED RATE LIMITING CONFIGURATION
 * We use 'validate: false' to stop the IPv6 keyGenerator errors.
 */

// A. Passive Limiter: For background syncs
const passiveLimiter = rateLimit({
  windowMs: 10 * 60 * 1000,
  max: 1000,
  standardHeaders: true,
  legacyHeaders: false,
  validate: false, // 🔥 THIS STOPS ALL VALIDATION ERRORS
  message: { success: false, message: "Background sync limit exceeded." }
});

// B. Auth Limiter: Stricter security for Login/Register
const authLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 30,
  standardHeaders: true,
  legacyHeaders: false,
  validate: false, // 🔥 THIS STOPS ALL VALIDATION ERRORS
  message: {
    success: false,
    message: "Too many authentication attempts. Please try again in an hour."
  }
});

// C. Global Limiter: General fallback
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 500,
  standardHeaders: true,
  legacyHeaders: false,
  validate: false, // 🔥 THIS STOPS ALL VALIDATION ERRORS
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

// For logging, we manually check the header or the trusted req.ip
app.use(morgan((tokens, req, res) => {
  const ip = req.headers['x-forwarded-for']?.split(',')[0] || req.ip;
  return [
    ip,
    tokens.method(req, res),
    tokens.url(req, res),
    tokens.status(req, res),
    tokens.res(req, res, 'content-length'), '-',
    tokens['response-time'](req, res), 'ms'
  ].join(' ');
}));

/**
 * 6. APPLY RATE LIMITERS STRATEGICALLY
 */
app.use('/api/v1/notifications/sync-token', passiveLimiter);
app.use('/api/v1/customers/dashboard', passiveLimiter);
app.use('/api/v1/auth/me', passiveLimiter);

app.use('/api/v1/auth/login', authLimiter);
app.use('/api/v1/auth/register', authLimiter);
app.use('/api/v1/auth/forgot-password', authLimiter);

app.use('/api/', globalLimiter);

// 7. Static Folders
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// 8. API routes
app.use('/api/v1', routes);

// Health root
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'GreenScrapHub API is Online',
    your_ip: req.headers['x-forwarded-for']?.split(',')[0] || req.ip,
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'production'
  });
});

// 9. 404 + error handlers
app.use(notFound);
app.use(errorHandler);

export default app;