defmodule Entranced.WorkerSupervisor do
  use DynamicSupervisor

  @me __MODULE__

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :no_args, name: @me)
  end

  def init(:no_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec add_worker(any) :: {:ok, pid()}
  def add_worker(client) do
    DynamicSupervisor.start_child(@me, {Entranced.Worker, client})
  end
end
