defmodule Quantum.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    :ok = Quantum.Telemetry.StatsdReporter.connect()

    :ok =
      :telemetry.attach(
        # unique handler id
        "quantum-telemetry-metrics",
        [:phoenix, :request],
        &Quantum.Telemetry.Metrics.handle_event/4,
        nil
      )

    # List all child processes to be supervised
    children = [
      Quantum.Repo,
      QuantumWeb.Endpoint,
      Quantum.Telemetry
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Quantum.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    QuantumWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
