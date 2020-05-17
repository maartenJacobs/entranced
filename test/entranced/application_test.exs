defmodule Entranced.ApplicationTest do
  use ExUnit.Case

  import ExUnit.CaptureLog
  require Logger

  @moduledoc """
  Test the basic functionality of the Entranced application, i.e. integration tests.

  Ideally there should be few of such tests, as we're connected directly through
  TCP sockets. This gets hairy real quick as we have to wait for the server to catch
  up.
  """

  test "clients are served random lines of data" do
    delay = Application.fetch_env!(:entranced, :write_delay_ms)

    capture_log(fn ->
      {:ok, socket} = :gen_tcp.connect('localhost', 2222, active: false)

      # Assert that 2 random messages were sent in a decent interval.
      {:ok, data} = :gen_tcp.recv(socket, 0, delay * 3)
      assert String.match?(to_string(data), ~r/^([A-F0-9]{1,8}\r\n)+$/)
      {:ok, data} = :gen_tcp.recv(socket, 0, delay * 3)
      assert String.match?(to_string(data), ~r/^([A-F0-9]{1,8}\r\n)+$/)

      :gen_tcp.close(socket)

      :timer.sleep(delay * 3)
    end)
  end

  test "server logs number of connections" do
    delay = Application.fetch_env!(:entranced, :write_delay_ms)

    output =
      capture_log(fn ->
        {:ok, socket} = :gen_tcp.connect('localhost', 2222, active: false)

        # Wait for the server to catch up.
        {:ok, _} = :gen_tcp.recv(socket, 0, delay * 3)

        :gen_tcp.close(socket)

        :timer.sleep(delay * 3)
      end)

    assert output =~ "New client connected! Now serving 1 clients."
    assert output =~ "Client disconnected! Now serving 0 clients."
  end
end
