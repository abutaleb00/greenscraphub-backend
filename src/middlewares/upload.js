// src/middlewares/upload.js
import multer from "multer";
import path from "path";
import fs from "fs";

// Ensure folder exists
const categoryDir = "uploads/category-icons";
if (!fs.existsSync(categoryDir)) {
    fs.mkdirSync(categoryDir, { recursive: true });
}

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, categoryDir);
    },
    filename: function (req, file, cb) {
        const ext = path.extname(file.originalname);
        const unique = Date.now() + "-" + Math.round(Math.random() * 1e9);
        cb(null, "cat-" + unique + ext);
    },
});

export const uploadCategoryIcon = multer({ storage });