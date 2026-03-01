import jwt from 'jsonwebtoken';
import ApiError from '../utils/ApiError.js';

/**
 * AUTH MIDDLEWARE
 * Handles JWT verification and Role-Based Access Control (RBAC)
 * @param {string|string[]} roles - Allowed roles (e.g., 'customer', ['rider', 'agent'])
 */
export const auth = (roles = []) => {
  // Convert single string role to array for consistency
  if (typeof roles === 'string') roles = [roles];

  return (req, res, next) => {
    const authHeader = req.headers.authorization;

    // 1. Check if Header exists
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return next(new ApiError(401, 'Access denied. No token provided.'));
    }

    const token = authHeader.split(' ')[1];

    try {
      // 2. Verify Token
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      // Attach user to request object
      req.user = decoded;

      // 3. Role Validation (RBAC)
      if (roles.length > 0) {
        // Normalize roles to lowercase to avoid 'Customer' vs 'customer' bugs
        const lowerCaseRoles = roles.map(r => r.toLowerCase());
        const userRole = decoded.role ? decoded.role.toLowerCase() : '';

        if (!lowerCaseRoles.includes(userRole)) {
          // LOG THE ERROR: This will show in your Node.js console
          console.error(`[AUTH ERROR] Role Mismatch: User has [${userRole}], but Route requires one of [${roles}]`);

          return next(new ApiError(403, `Forbidden: ${userRole} access denied for this resource.`));
        }
      }

      next();
    } catch (err) {
      if (err.name === 'TokenExpiredError') {
        return next(new ApiError(401, 'Your session has expired. Please login again.'));
      }
      next(new ApiError(401, 'Invalid token. Authorization failed.'));
    }
  };
};