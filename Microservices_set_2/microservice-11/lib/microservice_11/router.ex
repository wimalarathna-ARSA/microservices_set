defmodule Microservice11.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "Hello from Microservice 11 (Elixir)")
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end