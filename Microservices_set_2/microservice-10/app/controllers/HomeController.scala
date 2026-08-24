package controllers

import javax.inject._
import play.api._
import play.api.mvc._
import play.api.libs.json._
import java.time.Instant
import java.util.concurrent.atomic.AtomicLong

@Singleton
class HomeController @Inject()(val controllerComponents: ControllerComponents) extends BaseController {

  private val serviceName = sys.env.getOrElse("SERVICE_NAME", "service-scala-10")
  private val platform = sys.env.getOrElse("PLATFORM", "render")

  private val incomingRequests = new AtomicLong(0)
  private val processingRequests = new AtomicLong(0)

  def index() = Action { implicit request: Request[AnyContent] =>
    incomingRequests.incrementAndGet()
    val res = Ok("Hello from Microservice 10 (Scala Play)")
    processingRequests.incrementAndGet()
    res
  }

  def ping() = Action { implicit request: Request[AnyContent] =>
    incomingRequests.incrementAndGet()
    val json = Json.obj(
      "status" -> "ok",
      "service" -> serviceName
    )
    processingRequests.incrementAndGet()
    Ok(json)
  }

  def spike(duration: Option[Int]) = Action { implicit request: Request[AnyContent] =>
    incomingRequests.incrementAndGet()
    val dur = duration.getOrElse(10)
    val endTime = System.currentTimeMillis() + (dur * 1000L)
    while (System.currentTimeMillis() < endTime) {
      scala.math.sqrt(64.0 * 64.0 * 64.0 * 64.0)
    }
    val json = Json.obj(
      "message" -> s"CPU spiked for $dur seconds",
      "service" -> serviceName
    )
    processingRequests.incrementAndGet()
    Ok(json)
  }

  def metrics() = Action { implicit request: Request[AnyContent] =>
    val inc = incomingRequests.get()
    val proc = processingRequests.get()
    val queue = math.max(0, inc - proc)

    val json = Json.obj(
      "platform" -> platform,
      "service" -> serviceName,
      "timestamp" -> Instant.now().toString,
      "cpu_usage_percent" -> 0.0,
      "incoming_requests" -> inc,
      "processing_requests" -> proc,
      "queue_length" -> queue,
      "measurement_method" -> "application_runtime",
      "cpu_allocation" -> s"${Runtime.getRuntime().availableProcessors()}vCPU"
    )
    Ok(json)
  }
}