defmodule Adapter.Repo do
  use Ecto.Repo,
    otp_app: :adapter,
    adapter: Ecto.Adapters.Postgres
end
