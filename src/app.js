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
  crossOriginResourcePolicy: false, // Required to allow mobile apps to load images from your server
}));

// 2. CORS Configuration
// During development, allowing '*' is easiest for mobile testing
app.use(
  cors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
    credentials: true,
  })
);

// 3. Body Parsers
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(morgan('dev'));

// 4. Static Folders (CRITICAL for Mobile App to see images)
// This makes http://192.168.1.5:4000/uploads/categories/icon.png accessible
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// 5. API routes
app.use('/api/v1', routes);

// Health root
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'GreenScrapHub API',
    environment: process.env.NODE_ENV || 'development'
  });
});

// 6. 404 + error handlers
app.use(notFound);
app.use(errorHandler);

export default app;