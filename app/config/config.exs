# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :fish_finder,
  namespace: FF

# Configures the endpoint
config :fish_finder, FFWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "9du37yd+TtF5BpvdQA4BVXsADOz4AUIrUeUPkK8KJk8JDKD890KDHDGF",
  render_errors: [view: FFWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: FF.PubSub,
  live_view: [signing_salt: "aFaYPQRg"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :fish_finder, FF.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configures Elixir's Logger
# config :logger, :console,
#   format: "$time $metadata[$level] $message\n",
#   metadata: [:request_id]

# Configures Elixir's Logger for Loki and friends
config :logger, backends: [LoggerJSON]
config :fish_finder, FF.Repo, loggers: [{LoggerJSON.Ecto, :log, [:info]}]

config :logger_json, :backend,
  metadata: [
    :file,
    :line,
    :function,
    :module,
    :application,
    :httpRequest,
    :query,
    :request_id,
    :span_id,
    :trace_id
  ],
  formatter: FF.LoggerFormatter

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :opentelemetry, :resource, service: %{name: "fish_finder"}

config :opentelemetry, :processors,
  otel_batch_processor: %{
    exporter: {:opentelemetry_exporter, %{endpoints: [{:http, 'tempo', 55681, []}]}}
  }

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
