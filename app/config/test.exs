import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :fish_finder, FFWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "4xYUiZwHzleqC4N9MxP4AlvooaKJM1MU0zmkBE2+XaBVED3PLo+UrM1w1NsmWW2M",
  server: false

# In test we don't send emails.
config :fish_finder, FF.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
