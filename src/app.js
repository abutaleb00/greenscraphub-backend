import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import helmet from 'helmet';
import path from 'path';
import { fileURLToPath } from 'url';
import rateLimit from 'express-rate-limit';
import routes from './routes/index.js';
import { notFound, errorHandler } from './middlewares/errorHandler.js';
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const app = express();
import './services/marketingWorker.js';

app.set('trust proxy', 1);
app.use(helmet({
  crossOriginResourcePolicy: false,
  crossOriginEmbedderPolicy: false,
}));

const trackingLimiter = rateLimit({
  windowMs: 1 * 60 * 1000,
  max: process.env.NODE_ENV === 'development' ? 5000 : 120,
  standardHeaders: true,
  legacyHeaders: false,
  validate: false,
  message: { success: false, message: "Live tracking frequency limit reached. Please wait." }
});


const passiveLimiter = rateLimit({
  windowMs: 10 * 60 * 1000,
  max: 2000,
  standardHeaders: true,
  legacyHeaders: false,
  validate: false,
  message: { success: false, message: "Background sync limit exceeded." }
});

const authLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 50,
  standardHeaders: true,
  legacyHeaders: false,
  validate: false,
  message: {
    success: false,
    message: "Too many login attempts. Please try again in an hour."
  }
});

const globalLimiter = rateLimit({
  windowMs: 5 * 60 * 1000,
  max: 1000,
  standardHeaders: true,
  legacyHeaders: false,
  validate: false,
  message: {
    success: false,
    message: "Too many requests. For security, please wait 5 minutes."
  }
});

const allowedOrigins = [
  'http://localhost:3000',
  'http://localhost:3001',
  'https://greenscrap-web.vercel.app',
  'https://webapp.prosfata.space',
  'https://www.smartscrapbd.store',
  'www.smartscrapbd.store',
  'https://smartscrapbd.store',
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

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

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

app.use('/api/v1/pickups', trackingLimiter);
app.use('/api/v1/notifications/sync-token', passiveLimiter);
app.use('/api/v1/customers/dashboard', passiveLimiter);
app.use('/api/v1/auth/me', passiveLimiter);
app.use('/api/v1/auth/login', authLimiter);
app.use('/api/v1/auth/register', authLimiter);
app.use('/api/v1/auth/forgot-password', authLimiter);
app.use('/api/', globalLimiter);
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));
app.use('/api/v1', routes);

app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'GreenScrapHub API is Online',
    your_ip: req.headers['x-forwarded-for']?.split(',')[0] || req.ip,
    environment: process.env.NODE_ENV || 'production'
  });
});
app.use(notFound);
app.use(errorHandler);
export default app;