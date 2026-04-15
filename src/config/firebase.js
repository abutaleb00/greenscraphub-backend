import admin from "firebase-admin";
import { createRequire } from "module";

// Create a require function to load the JSON service account file
const require = createRequire(import.meta.url);
const serviceAccount = require("../../firebase-service-account.json");

// Prevent re-initializing if the app is already running (useful for nodemon)
if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
    });
    console.log("[Firebase] Admin SDK Initialized");
}

export default admin;