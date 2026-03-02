import multer from "multer";
import path from "path";
import fs from "fs";

// Ensure folder exists
const pickupDir = "uploads/pickups";
if (!fs.existsSync(pickupDir)) {
    fs.mkdirSync(pickupDir, { recursive: true });
}

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, pickupDir);
    },
    filename: function (req, file, cb) {
        const ext = path.extname(file.originalname);
        const unique = Date.now() + "-" + Math.round(Math.random() * 1e9);
        // Use fieldname prefix (e.g., item_photos[0]-123.jpg)
        cb(null, file.fieldname + "-" + unique + ext);
    },
});

export const uploadPickupPhotos = multer({
    storage,
    limits: { fileSize: 10 * 1024 * 1024 }, // 10MB
    fileFilter: (req, file, cb) => {
        const filetypes = /jpeg|jpg|png|webp/;
        const mimetype = filetypes.test(file.mimetype);
        const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
        if (mimetype && extname) return cb(null, true);
        cb(new Error("Only images are allowed (jpeg, jpg, png, webp)"));
    }
});