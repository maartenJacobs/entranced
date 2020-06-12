defmodule Entranced.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    port = Application.fetch_env!(:entranced, :port)

    exclude_ips =
      Application.fetch_env!(:entranced, :exclude_ips)
      |> Enum.map(&Entranced.Inet.ip_range_to_int_range(&1))

    children = [
      {Entranced.Counter, name: Entranced.Counter},
      Entranced.WorkerSupervisor,
      Supervisor.child_spec({Task, fn -> Entranced.Server.accept(port, exclude_ips) end},
        restart: :permanent
      )
    ]

    opts = [strategy: :one_for_all, name: Entranced.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
