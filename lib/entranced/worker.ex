defmodule Entranced.Worker do
  use GenServer, restart: :temporary

  @moduledoc """
  A worker receives a client connection's socket and sends a random line
  of data to the socket every 10 seconds.
  """

  ## Client API

  def start_link(socket) do
    GenServer.start_link(__MODULE__, %{socket: socket, client_name: socket_name(socket)})
  end

  ## Callbacks

  @impl true
  @spec init(%{client_name: String.t(), socket: :inet.socket()}) ::
          {:ok, %{client_name: String.t(), socket: :inet.socket()}}
  def init(%{socket: _, client_name: client_name} = state) do
    Entranced.Counter.opened(Entranced.Counter, client_name)
    delay_serve()
    {:ok, state}
  end

  @impl true
  def handle_info(:serve, state) do
    serve(state)

    {:noreply, state}
  end

  ## Private

  defp serve(%{socket: socket, client_name: client_name}) do
    # Read and ignore any data that was sent by the client.
    # Then write a random line of text and continue.
    case :gen_tcp.recv(socket, 0, 1) do
      {:ok, _} -> write_line(socket, client_name)
      {:error, :timeout} -> write_line(socket, client_name)
      # :etimedout is an OS error. This is not strictly documented in gen_tcp.
      # See http://erlang.org/pipermail/erlang-questions/2013-September/075466.html
      {:error, :etimedout} -> disconnected(client_name)
      {:error, :closed} -> disconnected(client_name)
    end
  end

  defp write_line(socket, client_name) do
    case :gen_tcp.send(socket, random_line()) do
      :ok -> delay_serve()
      {:error, :closed} -> disconnected(client_name)
    end
  end

  defp disconnected(client_name) do
    Entranced.Counter.closed(Entranced.Counter, client_name)
    exit(:normal)
  end

  defp delay_serve() do
    Process.send_after(self(), :serve, Application.fetch_env!(:entranced, :write_delay_ms))
  end

  defp random_line() do
    :erlang.integer_to_list(:rand.uniform(:math.pow(2, 32) |> round), 16) ++ '\r\n'
  end

  @spec socket_name(:inet.socket()) :: String.t()
  defp socket_name(socket) do
    case :inet.sockname(socket) do
      {:ok, {:local, addr}} -> List.to_string(addr)
      {:ok, {addr, _}} -> addr_to_string(addr)
      {:error, _} -> "unknown client"
    end
  end

  defp addr_to_string(addr) do
    case :inet.ntoa(addr) do
      {:error, _} -> "unknown client"
      addr -> List.to_string(addr)
    end
  end
end
