defmodule Tschat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TschatWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:tschat, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Tschat.PubSub},
      # Start a worker by calling: Tschat.Worker.start_link(arg)
      # {Tschat.Worker, arg},

      # Start presence
      TschatWeb.Presence,
      # Start to serve requests, typically the last entry
      TschatWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tschat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TschatWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
