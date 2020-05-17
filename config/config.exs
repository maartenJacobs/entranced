import Config

config :entranced,
  port: 22,
  write_delay_ms: 10_000

import_config "#{Mix.env()}.exs"
