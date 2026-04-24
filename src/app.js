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
 * 1. PROXY CONFIGURATION (Critical for Public IP)
 * Enabling 'trust proxy' tells Express to trust the X-Forwarded-For header.
 * Set to true or 1 since you are using a cPanel/Nginx proxy.
 */
app.set('trust proxy', 1);

// 2. Enhanced Security Middlewares
app.use(helmet({
  crossOriginResourcePolicy: false,
  crossOriginEmbedderPolicy: false,
}));

/**
 * 3. RATE LIMITING CONFIGURATION
 * Prevents automated scripts and bots from crashing your server.
 */
// General limiter: 100 requests per 15 minutes per IP
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: "Too many requests from this IP, please try again after 15 minutes."
  }
});

// Stricter limiter for Auth: 10 attempts per hour (prevents brute-force)
const authLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 15,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: "Too many authentication attempts. Please try again in an hour."
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
      if (!origin) return callback(null, true);
      if (allowedOrigins.indexOf(origin) !== -1 || process.env.NODE_ENV === 'development') {
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

// 6. Apply Rate Limiters
// Apply global limiter to all /api routes
app.use('/api/', globalLimiter);

// Apply strict limiter to sensitive Auth routes
app.use('/api/v1/auth/login', authLimiter);
app.use('/api/v1/auth/register', authLimiter);
app.use('/api/v1/auth/forgot-password', authLimiter);

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