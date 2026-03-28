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

// 1. Enhanced Security Middlewares
app.use(helmet({
  crossOriginResourcePolicy: false,
  crossOriginEmbedderPolicy: false, // Additional fix for loading media in browsers
}));

// 2. Optimized CORS Configuration
const allowedOrigins = [
  'http://localhost:3000', // Your Next.js Web Panel
  'http://localhost:3001', // Potential secondary dev port
  'https://greenscrap-web.vercel.app', // Potential secondary dev port
  'https://webapp.prosfata.space', // Potential secondary dev port
  'https://www.smartscrapbd.store', // Potential secondary dev port
  // Add your production domain here later
];

app.use(
  cors({
    origin: function (origin, callback) {
      // Allow requests with no origin (like mobile apps or curl)
      if (!origin) return callback(null, true);

      if (allowedOrigins.indexOf(origin) !== -1 || process.env.NODE_ENV === 'development') {
        callback(null, true);
      } else {
        callback(new Error('Not allowed by CORS'));
      }
    },
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
    credentials: true, // Required for Axios withCredentials: true
  })
);

// 3. Body Parsers
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(morgan('dev'));

// 4. Static Folders
// Added a check to ensure the path is absolute and correct
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// 5. API routes
app.use('/api/v1', routes);

// Health root
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'GreenScrapHub API is Online',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// 6. 404 + error handlers
app.use(notFound);
app.use(errorHandler);

export default app;