// Change require to import
import admin from '../config/firebase.js';

/**
 * Send Push Notification
 * @param {string} token - The user's FCM token
 * @param {string} title - Notification Title
 * @param {string} body - Notification Body
 * @param {object} extraData - Data for navigation
 */
export const sendPushNotification = async (token, title, body, extraData = {}) => {
    const message = {
        notification: {
            title: title,
            body: body,
        },
        data: {
            ...extraData,
            // Ensure all values in 'data' are strings
            click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
        token: token,
    };

    try {
        const response = await admin.messaging().send(message);
        console.log("Successfully sent message:", response);
        return response;
    } catch (error) {
        console.error("Error sending message:", error);
        throw error;
    }
};