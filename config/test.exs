use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bank_accounting, BankAccountingWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :bank_accounting, BankAccounting.Repo,
  username: "postgres",
  password: "123456",
  database: "bank_accounting_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
