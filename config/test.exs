use Mix.Config

config :orcid_adapter, OrcidAdapter.Repo,
  hostname: "127.0.0.1",
  port: "5432",
  username: "postgres",
  password: "",
  database: "exida_dev",
  show_sensitive_data_on_connection_error: false,
  timeout: 60000

config :orcid_adapter,
  ecto_repos: [OrcidAdapter.Repo],
  cross_ref_id: "vanessa.lee@interfolio.com",
  orcid_client_id: "APP-GICM51RXINSQOGAB",
  orcid_client_secret: "141c5bc2-a579-4d65-acdf-cf05f2fe954c",
  orcid_token: "5ff29d10-175b-4096-bff6-baa1c651f5fd"
