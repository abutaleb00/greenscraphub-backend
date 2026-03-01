import ApiError from '../utils/ApiError.js';

// 404 handler
export const notFound = (req, res, next) => {
  next(new ApiError(404, 'Not found'));
};

// Global error handler
export const errorHandler = (err, req, res, next) => {
  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal server error';

  if (process.env.NODE_ENV !== 'production') {
    console.error(err);
  }

  res.status(statusCode).json({
    success: false,
    message,
  });
};
