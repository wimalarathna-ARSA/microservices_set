defmodule Microservice11.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Microservice11.Router, options: [port: 3011]}
    ]
    opts = [strategy: :one_for_one, name: Microservice11.Supervisor]
    Supervisor.start_link(children, opts)
  end
end