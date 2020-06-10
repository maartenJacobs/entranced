defmodule Entranced.Counter do
  use Agent
  require Logger

  def start_link(opts) do
    Agent.start_link(fn -> 0 end, opts)
  end

  @spec opened(atom | pid | {atom, any} | {:via, atom, any}, String.t()) :: :ok
  def opened(counter, client_name) do
    Agent.update(counter, &record_opened(&1, client_name))
  end

  defp record_opened(count, client_name) do
    Logger.info("New client connected (#{client_name})! Now serving #{count + 1} clients.")
    count + 1
  end

  @spec closed(atom | pid | {atom, any} | {:via, atom, any}, String.t()) :: :ok
  def closed(counter, client_name) do
    Agent.update(counter, &record_closed(&1, client_name))
  end

  defp record_closed(count, client_name) do
    Logger.info("Client disconnected (#{client_name})! Now serving #{count - 1} clients.")
    count - 1
  end
end
