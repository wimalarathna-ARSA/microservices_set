defmodule Microservice11.MixProject do
  use Mix.Project

  def project do
    [
      app: :microservice_11,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Microservice11.Application, []}
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.14.0"},
      {:plug_cowboy, "~> 2.5.2"},
      {:cowlib, "~> 2.11.0", override: true}
    ]
  end
end