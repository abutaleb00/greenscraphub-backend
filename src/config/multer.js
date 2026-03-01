import multer from "multer";
import path from "path";
import fs from "fs";

// Make sure uploads folder exists
const uploadDir = "uploads/items";
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        const ext = path.extname(file.originalname);
        const uniqueName = `${Date.now()}-${Math.round(
            Math.random() * 1e9
        )}${ext}`;
        cb(null, uniqueName);
    },
});

export const upload = multer({ storage });
