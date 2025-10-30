const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

const appPool = process.env.APP_POOL || 'unknown';
const releaseId = process.env.RELEASE_ID || 'unknown';

let chaosMode = false;

app.use(express.json());

// Add headers to all responses
app.use((req, res, next) => {
    res.set('X-App-Pool', appPool);
    res.set('X-Release-Id', releaseId);
    next();
});

app.get('/', (req, res) => {
    res.json({
        message: 'Blue/Green Deployment Demo',
        pool: appPool,
        releaseId: releaseId,
        endpoints: {
            version: '/version',
            health: '/health',
            chaos_start: 'POST /chaos/start',
            chaos_stop: 'POST /chaos/stop'
        }
    });
});

app.get('/version', (req, res) => {
    if (chaosMode) {
        return res.status(500).json({ error: 'Service unavailable' });
    }
    res.json({
        pool: appPool,
        releaseId: releaseId,
        timestamp: new Date().toISOString()
    });
});

app.get('/health', (req, res) => {
    if (chaosMode) {
        return res.status(500).json({ status: 'unhealthy' });
    }
    res.json({ status: 'healthy', pool: appPool });
});

app.post('/chaos/start', (req, res) => {
    chaosMode = true;
    res.json({ message: `Chaos mode enabled for ${appPool}` });
});

app.post('/chaos/stop', (req, res) => {
    chaosMode = false;
    res.json({ message: `Chaos mode disabled for ${appPool}` });
});

app.listen(port, () => {
    console.log(`${appPool} app listening on port ${port}`);
});