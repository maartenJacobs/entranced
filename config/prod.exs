import Config

# Repetitive code to load a range of IPs from the environment variables
# EXCLUDE_MIN_IP (inclusive minimim IP) and EXCLUDE_MAX_IP (inclusive
# maximum IP). Currently only 1 range is configured.
exclude_min_ip =
  case System.get_env("EXCLUDE_MIN_IP") do
    nil ->
      nil

    ip when is_binary(ip) ->
      {:ok, ip_addr} = ip |> String.to_charlist() |> :inet.parse_address()
      ip_addr
  end

exclude_max_ip =
  case System.get_env("EXCLUDE_MAX_IP") do
    nil ->
      nil

    ip when is_binary(ip) ->
      {:ok, ip_addr} = ip |> String.to_charlist() |> :inet.parse_address()
      ip_addr
  end

exclude_ips =
  case {exclude_min_ip, exclude_max_ip} do
    {nil, nil} ->
      []

    {exclude_min_ip, exclude_max_ip}
    when not is_nil(exclude_min_ip) and
           not is_nil(exclude_max_ip) ->
      [{exclude_min_ip, exclude_max_ip}]
  end

config :entranced,
  port: 22,
  write_delay_ms: 1_000,
  # Ranges of IPs to disconnect immediately.
  exclude_ips: exclude_ips
