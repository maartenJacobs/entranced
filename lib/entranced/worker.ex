defmodule Entranced.Worker do
  use GenServer, restart: :temporary

  @moduledoc """
  A worker receives a client connection's socket and sends a random line
  of data to the socket every 10 seconds.
  """

  ## Client API

  def start_link(socket) do
    GenServer.start_link(__MODULE__, socket)
  end

  ## Callbacks

  @impl true
  def init(socket) do
    Entranced.Counter.opened(Entranced.Counter)
    delay_serve()
    {:ok, socket}
  end

  @impl true
  def handle_info(:serve, socket) do
    serve(socket)

    {:noreply, socket}
  end

  ## Private

  defp serve(socket) do
    # Read and ignore any data that was sent by the client.
    # Then write a random line of text and continue.
    case :gen_tcp.recv(socket, 0, 1) do
      {:ok, _} -> write_line(socket)
      {:error, :timeout} -> write_line(socket)
      {:error, :closed} -> disconnected()
    end
  end

  defp write_line(socket) do
    case :gen_tcp.send(socket, random_line()) do
      :ok -> delay_serve()
      {:error, :closed} -> disconnected()
    end
  end

  defp disconnected() do
    Entranced.Counter.closed(Entranced.Counter)
    exit(:normal)
  end

  defp delay_serve() do
    Process.send_after(self(), :serve, Application.fetch_env!(:entranced, :write_delay_ms))
  end

  defp random_line() do
    :erlang.integer_to_list(:rand.uniform(:math.pow(2, 32) |> round), 16) ++ '\r\n'
  end
end
