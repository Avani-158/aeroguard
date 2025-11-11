# Web Dashboard for IoT Air Quality Monitor

A simple HTML/CSS/JavaScript web dashboard as an alternative to the Flutter mobile app.

## Features

- Real-time AQI display with color-coded indicators
- Sensor readings (Temperature, Humidity, Noise, PM2.5)
- Control panel for sprinkler and buzzer
- Fire/smoke alerts
- AQI chart visualization
- Responsive design with Bootstrap

## Setup

1. **Configure Firebase**

   Edit `app.js` and replace the Firebase configuration:

   ```javascript
   const firebaseConfig = {
       apiKey: "YOUR_API_KEY",
       authDomain: "YOUR_PROJECT.firebaseapp.com",
       databaseURL: "https://YOUR_PROJECT.firebaseio.com",
       // ... rest of config
   };
   ```

2. **Set Up Firebase Realtime Database Rules**

   For development, you can use test mode. For production, set up proper authentication.

3. **Serve the Files**

   You can use any web server:

   ```bash
   # Using Python
   python -m http.server 8000

   # Using Node.js (http-server)
   npx http-server

   # Using PHP
   php -S localhost:8000
   ```

4. **Open in Browser**

   Navigate to `http://localhost:8000`

## Firebase Database Structure

The dashboard expects data in this format:

```json
{
  "devices": {
    "ESP32_001": {
      "aqi": 95,
      "temperature": 28.3,
      "humidity": 65,
      "pm2_5": 35,
      "pm10": 45,
      "noise": 60,
      "smoke": false,
      "fire": false,
      "sprinkler": "off",
      "buzzer": "off",
      "timestamp": "2025-01-19T12:30:00Z",
      "online": true
    }
  }
}
```

## Customization

- Modify `index.html` for UI changes
- Update `app.js` for functionality changes
- Adjust Bootstrap classes for styling
- Add more charts using Chart.js

## Notes

- This is a simple client-side dashboard
- For production, add authentication
- Consider using Firebase Hosting for deployment
- Add error handling and loading states
- Implement proper security rules

