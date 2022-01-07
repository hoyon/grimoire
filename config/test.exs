import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :grimoire, GrimoireWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "XQuVFQyKZWbShiktu/vN5g4Xm9U8AGdEgBLDLXXefpX7fRPWEi/W81sdPHxv4haT",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
