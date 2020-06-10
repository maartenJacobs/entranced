defmodule Entranced.Server do
  require Logger

  @spec accept(:inet.port_number()) :: no_return
  def accept(port) do
    {:ok, listen_sock} =
      :gen_tcp.listen(port, [
        :binary,
        # No packaging is done as we'll be throwing away the request anyway.
        packet: :raw,
        # Blocks on `:gen_tcp.recv()` until data is available.
        active: false,
        # Reuse address if listener crashes
        reuseaddr: true
      ])

    Logger.info("Accepting connections on #{port}")
    loop_acceptor(listen_sock)
  end

  defp loop_acceptor(listen_sock) do
    {:ok, client} = :gen_tcp.accept(listen_sock)
    {:ok, pid} = Entranced.WorkerSupervisor.add_worker(client)
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(listen_sock)
  end
end
