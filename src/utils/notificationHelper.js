import axios from 'axios';

/**
 * Send Push Notification via Expo Push API
 * * @param {string} token - The user's ExponentPushToken[...]
 * @param {string} title - Notification Title
 * @param {string} body - Notification Body
 * @param {object} extraData - Data for navigation (must be string values)
 */
export const sendPushNotification = async (token, title, body, extraData = {}) => {
    // 1. Validate if it is a valid Expo token
    if (!token || !token.startsWith('ExponentPushToken')) {
        console.error("[Push] Invalid token format. Must be an ExponentPushToken.");
        return null;
    }

    // 2. Prepare the Expo Message Format
    const message = {
        to: token,
        sound: 'default',
        title: title,
        body: body,
        data: extraData, // Extra data like { orderId: '14' }
        priority: 'high',
        _displayInForeground: true, // Helper for some older Expo versions
    };

    try {
        // 3. Post to Expo's universal push gateway
        const response = await axios.post('https://exp.host/--/api/v2/push/send', message, {
            headers: {
                'Accept': 'application/json',
                'Accept-encoding': 'gzip, deflate',
                'Content-Type': 'application/json',
            },
        });

        console.log("[Push Success] Expo Response:", response.data);
        return response.data;
    } catch (error) {
        // Log details but don't crash the main process
        if (error.response) {
            console.error("[Push Error] Expo Server Rejected:", error.response.data);
        } else {
            console.error("[Push Error] Connection Failed:", error.message);
        }
        return null;
    }
};