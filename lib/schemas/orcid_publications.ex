defmodule OrcidAdapter.Schemas.OrcidPublications do
  use Ecto.Schema

  schema "orcid_publications" do
    field :orcid, :string
    field :pid, :string
    field :external_ids, {:array, :map}
    field :journal, :string
    field :source, :string
    field :title, :string
    field :type, :string
    field :year, :integer
  end
end
