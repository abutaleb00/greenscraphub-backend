import jwt from 'jsonwebtoken';
import ApiError from '../utils/ApiError.js';

export const auth = (roles = []) => {
  if (typeof roles === 'string') roles = [roles];

  return (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return next(new ApiError(401, 'No token provided'));
    }

    const token = authHeader.split(' ')[1];

    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      req.user = decoded;

      if (roles.length && !roles.includes(decoded.role)) {
        return next(new ApiError(403, 'Forbidden'));
      }

      next();
    } catch (err) {
      next(new ApiError(401, 'Invalid or expired token'));
    }
  };
};
