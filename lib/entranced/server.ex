defmodule Entranced.Server do
  require Logger

  @spec accept(:inet.port_number(), [{pos_integer(), pos_integer()}]) :: no_return
  def accept(port, exclude_ips) do
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
    loop_acceptor(listen_sock, exclude_ips)
  end

  defp loop_acceptor(listen_sock, exclude_ips) do
    {:ok, client} = :gen_tcp.accept(listen_sock)
    handle_accepted(client, exclude_ips)
    loop_acceptor(listen_sock, exclude_ips)
  end

  defp handle_accepted(client, exclude_ips) do
    if exclude?(client, exclude_ips) do
      IO.puts("Closing connection from excluded IP")
      :gen_tcp.close(client)
    else
      {:ok, pid} = Entranced.WorkerSupervisor.add_worker(client)
      :ok = :gen_tcp.controlling_process(client, pid)
    end
  end

  defp exclude?(_, []) do
    false
  end

  defp exclude?(socket, exclude_ips) do
    ip_addr =
      case :inet.sockname(socket) do
        {:ok, {ip_addr, _}} -> ip_addr |> Entranced.Inet.ip_addr_to_int()
        _ -> nil
      end

    ip_addr != nil and
      Enum.any?(exclude_ips, fn {min, max} -> ip_addr >= min and ip_addr <= max end)
  end
end
