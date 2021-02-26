defmodule OrcidAdapter.Schemas.OrcidEmployment do
  use Ecto.Schema

  schema "orcid_employment" do
    field :orcid, :string
    field :pid, :string
    field :affiliation, :string
    field :department, :string
    field :role, :string
    field :start_date, :integer
    field :end_date, :integer
  end
end
