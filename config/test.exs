use Mix.Config

config :orcid_adapter, Adapter.Repo,
  username: "postgres",
  password: "",
  database: "exida_test",
  show_sensitive_data_on_connection_error: true,
  pool: Ecto.Adapters.SQL.Sandbox,
  log: false,
  loggers: []

config :orcid_adapter,
  ecto_repos: [Adapter.Repo],
  cross_ref_id: "vanessa.lee@interfolio.com",
  orcid_client_id: "APP-GICM51RXINSQOGAB",
  orcid_client_secret: "141c5bc2-a579-4d65-acdf-cf05f2fe954c",
  orcid_token: "5ff29d10-175b-4096-bff6-baa1c651f5fd"
