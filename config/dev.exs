import Config

config :entranced,
  port: 2222,
  write_delay_ms: 1_000,
  # Ranges of IPs to disconnect immediately.
  exclude_ips: [
    {{127, 0, 1, 0}, {127, 0, 1, 0}}
  ]
