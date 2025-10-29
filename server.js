import express from 'express';

const app = express();

const port = parseInt(process.env.PORT || process.env.APP_PORT || '3000', 10);
const appPool = process.env.APP_POOL || 'unknown';
const releaseId = process.env.RELEASE_ID || '';

let chaosErrorEnabled = false;

app.use((req, res, next) => {
  if (chaosErrorEnabled && !req.path.startsWith('/chaos')) {
    res.set('X-App-Pool', appPool);
    res.set('X-Release-Id', releaseId);
    return res.status(500).json({ error: 'Chaos mode error' });
  }
  next();
});

app.get('/version', (req, res) => {
  res.set('X-App-Pool', appPool);
  res.set('X-Release-Id', releaseId);
  res.json({ pool: appPool, releaseId, uptimeSeconds: process.uptime() });
});

app.get('/health', (req, res) => {
  res.status(200).send('OK');
});

app.get('/', (req, res) => {
  res.set('X-App-Pool', appPool);
  res.set('X-Release-Id', releaseId);
  res.json({
    message: 'Blue/Green demo service',
    pool: appPool,
    releaseId,
    endpoints: ['/version', '/health', '/chaos/start?mode=error', '/chaos/stop']
  });
});

app.post('/chaos/start', (req, res) => {
  const mode = (req.query.mode || '').toString();
  if (mode === 'error') {
    chaosErrorEnabled = true;
    return res.json({ status: 'started', mode: 'error' });
  }
  return res.status(400).json({ error: 'Unsupported mode. Use mode=error' });
});

app.post('/chaos/stop', (req, res) => {
  chaosErrorEnabled = false;
  res.json({ status: 'stopped' });
});

app.listen(port, () => {
  // eslint-disable-next-line no-console
  console.log(`App listening on port ${port} (pool=${appPool}, releaseId=${releaseId})`);
});


