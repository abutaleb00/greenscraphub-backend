import multer from "multer";
import path from "path";
import fs from "fs";

/**
 * Helper to ensure upload directories exist
 * @param {string} dirPath 
 */
const ensureDir = (dirPath) => {
    if (!fs.existsSync(dirPath)) {
        fs.mkdirSync(dirPath, { recursive: true });
    }
};

// 1. Define Directories
const CATEGORY_DIR = "uploads/category-icons";
const SCRAP_ITEM_DIR = "uploads/scrap-items";

// Ensure folders are created on initialization
ensureDir(CATEGORY_DIR);
ensureDir(SCRAP_ITEM_DIR);

/**
 * Storage configuration for Category Icons
 */
const categoryStorage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, CATEGORY_DIR);
    },
    filename: function (req, file, cb) {
        const ext = path.extname(file.originalname);
        const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
        cb(null, `cat-${uniqueSuffix}${ext}`);
    },
});

/**
 * Storage configuration for Scrap Item Images
 */
const scrapItemStorage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, SCRAP_ITEM_DIR);
    },
    filename: function (req, file, cb) {
        const ext = path.extname(file.originalname);
        const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
        cb(null, `item-${uniqueSuffix}${ext}`);
    },
});

/**
 * File Filter to ensure only images are uploaded
 */
const fileFilter = (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|webp/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);

    if (mimetype && extname) {
        return cb(null, true);
    } else {
        cb(new Error("Only images (jpeg, jpg, png, webp) are allowed!"));
    }
};

// Export specific middleware instances
export const uploadCategoryIcon = multer({
    storage: categoryStorage,
    fileFilter,
    limits: { fileSize: 2 * 1024 * 1024 } // 2MB limit
});

export const uploadScrapItemImage = multer({
    storage: scrapItemStorage,
    fileFilter,
    limits: { fileSize: 5 * 1024 * 1024 } // 5MB limit
});