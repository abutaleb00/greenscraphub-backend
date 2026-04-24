import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import helmet from 'helmet';
import path from 'path';
import { fileURLToPath } from 'url';
import routes from './routes/index.js';
import { notFound, errorHandler } from './middlewares/errorHandler.js';

// Setup __dirname for ESM
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();

/**
 * 1. PROXY CONFIGURATION (Critical for Public IP)
 * Enabling 'trust proxy' tells Express to trust the X-Forwarded-For header
 * sent by Nginx, Cloudflare, or DigitalOcean Load Balancers.
 */
app.set('trust proxy', true);

// 2. Enhanced Security Middlewares
app.use(helmet({
  crossOriginResourcePolicy: false,
  crossOriginEmbedderPolicy: false,
}));

// 3. Optimized CORS Configuration
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
      // Allow requests with no origin (like mobile apps)
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

// 4. Body Parsers & Logging
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

/**
 * Custom Morgan Format to log Public IP in console during development/production
 */
app.use(morgan(':remote-addr :method :url :status :res[content-length] - :response-time ms'));

// 5. Static Folders
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// 6. API routes
app.use('/api/v1', routes);

// Health root
app.get('/', (req, res) => {
  // Logic to show user their own IP on the health check
  const publicIp = req.ip || req.headers['x-forwarded-for'] || req.socket.remoteAddress;

  res.json({
    success: true,
    message: 'GreenScrapHub API is Online',
    your_ip: publicIp,
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'production'
  });
});

// 7. 404 + error handlers
app.use(notFound);
app.use(errorHandler);

export default app;