import os
import time
import math
import psutil
from datetime import datetime, timezone
from flask import Flask, request, jsonify

app = Flask(__name__)

# Config
PORT = int(os.environ.get('PORT', 3002))
SERVICE_NAME = os.environ.get('SERVICE_NAME', 'service-python-02')
PLATFORM = os.environ.get('PLATFORM', 'render')

incoming_requests = 0
processing_requests = 0

@app.before_request
def before_request():
    global incoming_requests
    if request.path not in ['/ping', '/metrics']: # Optional: Exclude health routes from queue tracking? We'll include all to be consistent.
        pass
    incoming_requests += 1

@app.after_request
def after_request(response):
    global processing_requests
    processing_requests += 1
    return response

@app.route('/')
def hello():
    return 'Hello from Microservice 02 (Python Flask)'

@app.route('/ping')
def ping():
    return jsonify({"status": "ok", "service": SERVICE_NAME})

@app.route('/spike')
def spike():
    duration = int(request.args.get('duration', 10))
    end_time = time.time() + duration
    while time.time() < end_time:
        math.sqrt(64 ** 5)
    return jsonify({"message": f"CPU spiked for {duration} seconds", "service": SERVICE_NAME})

@app.route('/metrics')
def metrics():
    # Application runtime metrics for Render
    cpu_usage_percent = psutil.cpu_percent(interval=0.1)
    queue_length = max(0, incoming_requests - processing_requests)
    
    return jsonify({
        "platform": PLATFORM,
        "service": SERVICE_NAME,
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "cpu_usage_percent": cpu_usage_percent,
        "incoming_requests": incoming_requests,
        "processing_requests": processing_requests,
        "queue_length": queue_length,
        "measurement_method": "application_runtime",
        "cpu_allocation": f"{psutil.cpu_count()}vCPU"
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=PORT)