const http = require('http');
const os = require('os');

const PORT = process.env.PORT || 8080;
const APP_MESSAGE = process.env.APP_MESSAGE || 'Welcome to SafeHarbor Demo App!';
const APP_VERSION = process.env.APP_VERSION || 'v1.0.0';
const ENVIRONMENT = process.env.ENVIRONMENT || 'development';

const server = http.createServer((req, res) => {
  if (req.url === '/' && req.method === 'GET') {
    const response = {
      message: APP_MESSAGE,
      version: APP_VERSION,
      environment: ENVIRONMENT,
      timestamp: new Date().toISOString(),
      hostname: os.hostname(),
      status: 'healthy'
    };

    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(response, null, 2));
  } else if (req.url === '/health' && req.method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'healthy' }));
  } else {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Not found' }));
  }
});

server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Environment: ${ENVIRONMENT}`);
  console.log(`Version: ${APP_VERSION}`);
});
