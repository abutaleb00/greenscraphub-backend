import ApiError from '../utils/ApiError.js';

/**
 * 404 Not Found Middleware
 * Triggers when a request is made to a route that doesn't exist
 */
export const notFound = (req, res, next) => {
  const error = new ApiError(404, `Path not found - ${req.originalUrl}`);
  next(error);
};

/**
 * Global Error Handler Middleware
 * Catches all errors thrown in the app and formats them for the Mobile App
 */
export const errorHandler = (err, req, res, next) => {
  let error = err;

  // 1. If it's not an instance of our custom ApiError, wrap it
  if (!(error instanceof ApiError)) {
    const statusCode = error.statusCode || (error.response ? error.response.status : 500);
    const message = error.message || "Something went wrong on the server";

    // Handle specific Rate Limit message if it exists
    const errorMessage = error.message === "Too many requests"
      ? "Too many attempts from this IP. Please try again later."
      : message;

    error = new ApiError(statusCode, errorMessage, err.errors || [], err.stack);
  }

  // 2. Log details for developers (but not in production logs if they are too noisy)
  if (process.env.NODE_ENV !== 'production') {
    console.error(`[Error] ${req.method} ${req.path} >>`, error.message);
    // console.error(err.stack); // Uncomment if you need full traces in terminal
  }

  // 3. Final formatted JSON response
  // This structure matches what our Premium Modal expects
  res.status(error.statusCode).json({
    success: false,
    message: error.message,
    errors: error.errors || [],
    // Include stack trace only in development mode for easier debugging
    ...(process.env.NODE_ENV === 'development' && { stack: error.stack })
  });
};