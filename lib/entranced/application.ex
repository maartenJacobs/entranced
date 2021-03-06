defmodule Entranced.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    port = Application.fetch_env!(:entranced, :port)

    children = [
      {Entranced.Counter, name: Entranced.Counter},
      Entranced.WorkerSupervisor,
      Supervisor.child_spec({Task, fn -> Entranced.Server.accept(port) end}, restart: :permanent)
    ]

    opts = [strategy: :one_for_all, name: Entranced.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
