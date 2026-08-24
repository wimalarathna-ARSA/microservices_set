import Vapor

let app = Application()

defer { app.shutdown() }

app.get { req in
    return "Hello from Microservice 20 (Swift Vapor)"
}

try app.run()