use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :wallets, WalletsWeb.Endpoint,
  http: [port: 4000],
  url: [port: 4000],
  static_url: [scheme: "http", host: "localhost", port: 8080],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack-dev-server/bin/webpack-dev-server.js",
      "--mode",
      "development",
      "--watch-stdin",
      "--config",
      "./webpack.dev.config.js",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

# Watch static and templates for browser reloading.
config :wallets, WalletsWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/wallets_web/views/.*(ex)$},
      ~r{lib/wallets_web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Configure your database
config :wallets, Wallets.Repo,
  username: "postgres",
  password: "postgres",
  database: "wallets_dev",
  hostname: "localhost",
  pool_size: 10
