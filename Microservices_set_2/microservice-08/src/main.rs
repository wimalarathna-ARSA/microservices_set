use actix_web::{web, App, HttpResponse, HttpServer, Responder};
use serde::Serialize;
use std::env;
use std::time::{Duration, Instant};

#[derive(Serialize)]
struct PingResponse {
    status: String,
    service: String,
}

#[derive(Serialize)]
struct SpikeResponse {
    message: String,
    service: String,
}

#[derive(serde::Deserialize)]
struct SpikeQuery {
    duration: Option<u64>,
}

async fn hello() -> impl Responder {
    HttpResponse::Ok().body("Hello from Microservice 08 (Rust Actix)")
}

async fn ping() -> impl Responder {
    let service_name = env::var("SERVICE_NAME").unwrap_or_else(|_| "service-rust-08".to_string());
    HttpResponse::Ok().json(PingResponse {
        status: "ok".to_string(),
        service: service_name,
    })
}

async fn spike(query: web::Query<SpikeQuery>) -> impl Responder {
    let service_name = env::var("SERVICE_NAME").unwrap_or_else(|_| "service-rust-08".to_string());
    let duration_secs = query.duration.unwrap_or(10);
    let end_time = Instant::now() + Duration::from_secs(duration_secs);

    while Instant::now() < end_time {
        let _ = (64.0f64).sqrt();
    }

    HttpResponse::Ok().json(SpikeResponse {
        message: format!("CPU spiked for {} seconds", duration_secs),
        service: service_name,
    })
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let port = env::var("PORT").unwrap_or_else(|_| "3008".to_string());
    let bind_addr = format!("0.0.0.0:{}", port);

    HttpServer::new(|| {
        App::new()
            .route("/", web::get().to(hello))
            .route("/ping", web::get().to(ping))
            .route("/spike", web::get().to(spike))
    })
    .bind(&bind_addr)?
    .run()
    .await
}