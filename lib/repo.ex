defmodule Adapter.Repo do
  use Ecto.Repo,
    otp_app: :orcid_adapter,
    adapter: Ecto.Adapters.Postgres
end
