defmodule Entranced.Inet do
  @spec ip_range_to_int_range({:inet.ip_address(), :inet.ip_address()}) ::
          {pos_integer(), pos_integer()}
  def ip_range_to_int_range({ip_addr_min, ip_addr_max}) do
    min = ip_addr_to_int(ip_addr_min)
    max = ip_addr_to_int(ip_addr_max)
    true = min <= max

    {min, max}
  end

  @spec ip_addr_to_int(:inet.ip_address()) :: pos_integer()
  def ip_addr_to_int(ip_addr) do
    ip_addr |> Tuple.to_list() |> :binary.list_to_bin() |> :binary.decode_unsigned()
  end
end
