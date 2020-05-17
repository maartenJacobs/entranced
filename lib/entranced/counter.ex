defmodule Entranced.Counter do
  use Agent
  require Logger

  def start_link(opts) do
    Agent.start_link(fn -> 0 end, opts)
  end

  def opened(counter) do
    Agent.update(counter, &record_opened/1)
  end

  defp record_opened(count) do
    Logger.info("New client connected! Now serving #{count + 1} clients.")
    count + 1
  end

  def closed(counter) do
    Agent.update(counter, &record_closed/1)
  end

  defp record_closed(count) do
    Logger.info("Client disconnected! Now serving #{count - 1} clients.")
    count - 1
  end
end
