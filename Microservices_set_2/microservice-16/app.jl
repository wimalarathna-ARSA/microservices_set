using HTTP

function hello(req::HTTP.Request)
    return HTTP.Response(200, "Hello from Microservice 16 (Julia HTTP.jl)")
end

HTTP.serve(hello, "0.0.0.0", 3016)