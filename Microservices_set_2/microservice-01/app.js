const express = require('express');
const os = require('os');
const app = express();
const port = process.env.PORT || 3001;
const serviceName = process.env.SERVICE_NAME || 'service-node-01';
const platform = process.env.PLATFORM || 'render';

let incomingRequests = 0;
let processingRequests = 0;
let httpErrors = 0;
let requestTimeouts = 0;
let lastLatencyMs = 0.0;
let lastHttpErrorWindow = 0;
const startTime = Date.now();

setInterval(() => { lastHttpErrorWindow = httpErrors; httpErrors = 0; }, 1000);

app.use((req, res, next) => {
    incomingRequests++;
    const reqStart = Date.now();
    res.on('finish', () => {
        processingRequests++;
        lastLatencyMs = Date.now() - reqStart;
        if (res.statusCode >= 400) httpErrors++;
    });
    next();
});

app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        service: serviceName,
        platform: platform,
        service_id: serviceName,
        target_reachable: true,
        health_check_failed: 0,
        latency_ms: lastLatencyMs,
        target: 'self'
    });
});

app.get('/', (req, res) => {
  res.send('Hello from Microservice 01 (Node.js Express)');
});

app.get('/ping', (req, res) => {
    res.json({ status: 'ok', service: serviceName });
});

app.get('/spike', (req, res) => {
    const duration = parseInt(req.query.duration || '10', 10);
    const endTime = Date.now() + duration * 1000;
    while (Date.now() < endTime) {
        Math.sqrt(64 * 64 * 64 * 64);
    }
    res.json({ message: `CPU spiked for ${duration} seconds`, service: serviceName });
});

let lastCpuUsage = process.cpuUsage();
let lastCpuTime = process.hrtime.bigint();
let currentCpuPercent = 0.0;

setInterval(() => {
    const currentCpuUsage = process.cpuUsage();
    const currentCpuTime = process.hrtime.bigint();
    
    const userDiff = currentCpuUsage.user - lastCpuUsage.user;
    const systemDiff = currentCpuUsage.system - lastCpuUsage.system;
    
    const timeDiff = Number(currentCpuTime - lastCpuTime) / 1000;
    if (timeDiff > 0) {
        const cpuPercent = ((userDiff + systemDiff) / timeDiff) * 100;
        currentCpuPercent = Math.min(100, cpuPercent / os.cpus().length);
    }
    
    lastCpuUsage = currentCpuUsage;
    lastCpuTime = currentCpuTime;
}, 1000);

app.get('/metrics', (req, res) => {
    const queueLength = incomingRequests - processingRequests;
    res.json({
        platform: platform,
        service: serviceName,
        timestamp: new Date().toISOString(),
        cpu_usage_percent: parseFloat(currentCpuPercent.toFixed(2)),
        incoming_requests: incomingRequests,
        processing_requests: processingRequests,
        queue_length: queueLength >= 0 ? queueLength : 0,
        latency_ms: lastLatencyMs,
        service_unreachable: 0,
        health_check_failed: 0,
        request_timeout: requestTimeouts > 0 ? 1 : 0,
        http_errors_per_sec: lastHttpErrorWindow,
        error_rate: incomingRequests > 0 ? parseFloat(((lastHttpErrorWindow) / Math.max(incomingRequests, 1)).toFixed(6)) : 0,
        uptime_seconds: Math.round((Date.now() - startTime) / 1000 * 100) / 100,
        measurement_method: 'application_runtime',
        cpu_allocation: `${os.cpus().length}vCPU`
    });
});

app.listen(port, () => {
  console.log(`Microservice 01 listening on port ${port}`);
});