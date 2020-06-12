import Config

config :entranced,
  port: 22,
  write_delay_ms: 10_000,
  # Ranges of IPs to disconnect immediately.
  exclude_ips: []

import_config "#{Mix.env()}.exs"
