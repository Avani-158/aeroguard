// Firebase Configuration
// Replace with your Firebase config
import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js';
import { getDatabase, ref, onValue, set } from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-database.js';

const firebaseConfig = {
    // Add your Firebase config here
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_PROJECT.firebaseapp.com",
    databaseURL: "https://YOUR_PROJECT.firebaseio.com",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_PROJECT.appspot.com",
    messagingSenderId: "YOUR_SENDER_ID",
    appId: "YOUR_APP_ID"
};

const app = initializeApp(firebaseConfig);
const database = getDatabase(app);
const deviceRef = ref(database, 'devices/ESP32_001');

// Chart setup
const ctx = document.getElementById('aqiChart').getContext('2d');
const aqiChart = new Chart(ctx, {
    type: 'line',
    data: {
        labels: [],
        datasets: [{
            label: 'AQI',
            data: [],
            borderColor: 'rgb(75, 192, 192)',
            tension: 0.1
        }]
    },
    options: {
        responsive: true,
        scales: {
            y: {
                beginAtZero: true
            }
        }
    }
});

// Update UI with device data
function updateUI(data) {
    if (!data) return;

    // AQI
    const aqi = data.aqi || 0;
    document.getElementById('aqiValue').textContent = `AQI: ${aqi.toFixed(0)}`;
    
    // AQI Circle
    const aqiCircle = document.getElementById('aqiCircle');
    const aqiColor = getAQIColor(aqi);
    aqiCircle.style.backgroundColor = aqiColor;
    aqiCircle.textContent = calculateAirScore(aqi);
    
    // AQI Category
    document.getElementById('aqiCategory').textContent = getAQICategory(aqi);
    document.getElementById('aqiCategory').className = `badge bg-${getAQICategoryClass(aqi)}`;
    
    // Air Score
    const airScore = calculateAirScore(aqi);
    document.getElementById('airScoreBar').style.width = `${airScore}%`;
    document.getElementById('airScoreBar').textContent = `${airScore}`;
    document.getElementById('airScoreBar').className = `progress-bar bg-${getAQICategoryClass(aqi)}`;
    
    // Sensors
    document.getElementById('temperature').textContent = (data.temperature || 0).toFixed(1);
    document.getElementById('humidity').textContent = (data.humidity || 0).toFixed(1);
    document.getElementById('noise').textContent = (data.noise || 0).toFixed(0);
    document.getElementById('pm25').textContent = (data.pm2_5 || 0).toFixed(1);
    
    // Status
    const statusEl = document.getElementById('deviceStatus');
    if (data.online) {
        statusEl.textContent = 'Online';
        statusEl.className = 'status-badge status-online';
    } else {
        statusEl.textContent = 'Offline';
        statusEl.className = 'status-badge status-offline';
    }
    
    // Fire Alert
    if (data.fire || data.smoke) {
        document.getElementById('fireAlert').style.display = 'block';
    } else {
        document.getElementById('fireAlert').style.display = 'none';
    }
    
    // Control Status
    document.getElementById('sprinklerStatus').textContent = (data.sprinkler || 'off').toUpperCase();
    document.getElementById('buzzerStatus').textContent = (data.buzzer || 'off').toUpperCase();
    
    // Update Chart
    const now = new Date().toLocaleTimeString();
    aqiChart.data.labels.push(now);
    aqiChart.data.datasets[0].data.push(aqi);
    
    // Keep only last 20 data points
    if (aqiChart.data.labels.length > 20) {
        aqiChart.data.labels.shift();
        aqiChart.data.datasets[0].data.shift();
    }
    
    aqiChart.update();
}

// Listen to Firebase Realtime Database
onValue(deviceRef, (snapshot) => {
    const data = snapshot.val();
    updateUI(data);
}, (error) => {
    console.error('Error reading data:', error);
});

// Control Functions
function toggleSprinkler() {
    const currentStatus = document.getElementById('sprinklerStatus').textContent.toLowerCase();
    const newStatus = currentStatus === 'on' ? 'off' : 'on';
    set(ref(database, 'devices/ESP32_001/sprinkler'), newStatus);
}

function toggleBuzzer() {
    const currentStatus = document.getElementById('buzzerStatus').textContent.toLowerCase();
    const newStatus = currentStatus === 'on' ? 'off' : 'on';
    set(ref(database, 'devices/ESP32_001/buzzer'), newStatus);
}

function acknowledgeFire() {
    set(ref(database, 'devices/ESP32_001/fire'), false);
    set(ref(database, 'devices/ESP32_001/smoke'), false);
}

// Helper Functions
function calculateAirScore(aqi) {
    if (aqi <= 50) return 100;
    if (aqi <= 100) return 80;
    if (aqi <= 150) return 60;
    if (aqi <= 200) return 40;
    if (aqi <= 300) return 20;
    return 0;
}

function getAQIColor(aqi) {
    if (aqi <= 50) return '#28a745';
    if (aqi <= 100) return '#ffc107';
    if (aqi <= 150) return '#fd7e14';
    if (aqi <= 200) return '#dc3545';
    if (aqi <= 300) return '#6f42c1';
    return '#5a0d0d';
}

function getAQICategory(aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
}

function getAQICategoryClass(aqi) {
    if (aqi <= 50) return 'success';
    if (aqi <= 100) return 'warning';
    if (aqi <= 150) return 'warning';
    if (aqi <= 200) return 'danger';
    if (aqi <= 300) return 'danger';
    return 'dark';
}

