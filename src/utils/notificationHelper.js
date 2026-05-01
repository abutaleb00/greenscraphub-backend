import axios from 'axios';

/**
 * Send Push Notification via Expo Push API
 * @param {string} token - The user's ExponentPushToken[...]
 * @param {string} title - Notification Title
 * @param {string} body - Notification Body
 * @param {object} extraData - Data for navigation
 * @param {string} targetApp - 'customer' or 'rider' (Defaults to 'customer')
 */
export const sendPushNotification = async (token, title, body, extraData = {}, targetApp = 'customer') => {
    // 1. Validate if it is a valid Expo token
    if (!token || !token.startsWith('ExponentPushToken')) {
        console.error("[Push] Invalid token format. Must be an ExponentPushToken.");
        return null;
    }

    // 2. Map target app settings
    const packageName = targetApp === 'rider' ? 'smartscrapbd.rider' : 'smartscrapbd.customer';
    const channelId = targetApp === 'rider' ? 'rider-notifications' : 'customer-notifications';

    // 3. Prepare the Expo Message Format
    const message = {
        to: token,
        sound: 'default',
        title: title,
        body: body,
        priority: 'high',
        channelId: channelId,
        data: {
            ...extraData,
            _fedora: packageName, // Ensures FCM directs it to the correct app package on the device
        },
        _displayInForeground: true,
    };

    try {
        // 4. Post to Expo's universal push gateway
        const response = await axios.post('https://exp.host/--/api/v2/push/send', message, {
            headers: {
                'Accept': 'application/json',
                'Accept-encoding': 'gzip, deflate',
                'Content-Type': 'application/json',
            },
        });

        console.log(`[Push Success] Expo Response (${targetApp}):`, response.data);
        return response.data;
    } catch (error) {
        if (error.response) {
            console.error(`[Push Error] Expo Server Rejected (${targetApp}):`, error.response.data);
        } else {
            console.error("[Push Error] Connection Failed:", error.message);
        }
        return null;
    }
};