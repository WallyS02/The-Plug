defmodule ThePlugPhoenix.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ThePlugPhoenixWeb.Telemetry,
      ThePlugPhoenix.Repo,
      {DNSCluster, query: Application.get_env(:the_plug_phoenix, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ThePlugPhoenix.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ThePlugPhoenix.Finch},
      # Start a worker by calling: ThePlugPhoenix.Worker.start_link(arg)
      # {ThePlugPhoenix.Worker, arg},
      # Start to serve requests, typically the last entry
      ThePlugPhoenixWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ThePlugPhoenix.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ThePlugPhoenixWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
