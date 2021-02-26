defmodule OrcidAdapter.Schemas.Orcid do
  use Ecto.Schema

  schema "orcid" do
    field :orcid, :string
    field :pid, :string
    field :external_ids, {:array, :map}
    field :family_name, :string
    field :given_names, :string
    field :credit_name, :string
    field :keywords, {:array, :string}
    field :other_names, {:array, :string}
  end
end
