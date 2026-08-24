package com.example

import io.ktor.server.application.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import java.time.Instant
import kotlin.math.sqrt

fun main() {
    val port = System.getenv("PORT")?.toIntOrNull() ?: 3009
    val serviceName = System.getenv("SERVICE_NAME") ?: "service-kotlin-09"

    embeddedServer(Netty, port = port, host = "0.0.0.0") {
        routing {
            get("/") {
                call.respondText("Hello from Microservice 09 (Kotlin Ktor)")
            }
            get("/ping") {
                call.respondText("""{"status":"ok","service":"$serviceName"}""", io.ktor.http.ContentType.Application.Json)
            }
            get("/spike") {
                val duration = call.request.queryParameters["duration"]?.toLongOrNull() ?: 10L
                val endTime = System.currentTimeMillis() + (duration * 1000L)
                while (System.currentTimeMillis() < endTime) {
                    sqrt(64.0 * 64.0 * 64.0 * 64.0)
                }
                call.respondText("""{"message":"CPU spiked for $duration seconds","service":"$serviceName"}""", io.ktor.http.ContentType.Application.Json)
            }
        }
    }.start(wait = true)
}