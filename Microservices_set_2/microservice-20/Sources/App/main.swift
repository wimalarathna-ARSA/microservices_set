import Vapor

let app = Application()

defer { app.shutdown() }

var incoming = 0
var processing = 0
var errors = 0
var lastLatency = 0.0

app.middleware.use(MetricsMiddleware { latency, status in
    lastLatency = latency
    if status >= 400 { errors += 1 }
})

app.get { req in
    incoming += 1
    let res = Response(status: .ok, body: .init(string: "Hello from Microservice 20 (Swift Vapor)"))
    processing += 1
    return res
}

app.get("ping") { req in
    incoming += 1
    let res = Response(status: .ok, headers: ["Content-Type": "application/json"], body: .init(string: "{\"status\":\"ok\",\"service\":\"service-swift-20\"}"))
    processing += 1
    return res
}

app.get("health") { req in
    incoming += 1
    let body = "{\"status\":\"ok\",\"service\":\"service-swift-20\",\"service_id\":\"service-swift-20\",\"target_reachable\":true,\"health_check_failed\":0,\"latency_ms\":\(lastLatency),\"target\":\"self\"}"
    let res = Response(status: .ok, headers: ["Content-Type": "application/json"], body: .init(string: body))
    processing += 1
    return res
}

app.get("metrics") { req in
    incoming += 1
    let queue = max(0, incoming - processing)
    let body = "{\"platform\":\"render\",\"service\":\"service-swift-20\",\"cpu_usage_percent\":0.0,\"incoming_requests\":\(incoming),\"processing_requests\":\(processing),\"queue_length\":\(queue),\"latency_ms\":\(lastLatency),\"service_unreachable\":0,\"health_check_failed\":0,\"request_timeout\":0,\"http_errors_per_sec\":\(errors),\"error_rate\":0.0,\"uptime_seconds\":0.0,\"measurement_method\":\"application_runtime\",\"cpu_allocation\":\"unknown\"}"
    let res = Response(status: .ok, headers: ["Content-Type": "application/json"], body: .init(string: body))
    processing += 1
    return res
}

app.get("spike") { req -> Response in
    incoming += 1
    let duration = req.query["duration"] as Int? ?? 10
    let end = Date().addingTimeInterval(TimeInterval(duration))
    while Date() < end {
        _ = sqrt(pow(64.0, 5.0))
    }
    let res = Response(status: .ok, headers: ["Content-Type": "application/json"], body: .init(string: "{\"message\":\"CPU spiked for \(duration) seconds\",\"service\":\"service-swift-20\"}"))
    processing += 1
    return res
}

struct MetricsMiddleware: Middleware {
    var counter: (Double, Int) -> Void

    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        let start = Date()
        let response = try await next.respond(to: request)
        let ms = Date().timeIntervalSince(start) * 1000
        counter(ms, Int(response.status.code))
        return response
    }
}

try app.run()
