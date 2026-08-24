local lapis = require("lapis")

local app = lapis.Application()

app:get("/", function(self)
  return "Hello from Microservice 17 (Lua Lapis)"
end)

return app