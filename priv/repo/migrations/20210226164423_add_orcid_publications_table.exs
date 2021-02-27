defmodule Adapter.Repo.Migrations.AddOrcidPublicationsTable do
  use Ecto.Migration

  def change do
    create table(:orcid_publications) do
      add :orcid, :string
      add :pid, :string
      add :external_ids, {:array, :map}
      add :journal, :string
      add :source, :string
      add :title, :string
      add :type, :string
      add :year, :integer
    end
  end
end
