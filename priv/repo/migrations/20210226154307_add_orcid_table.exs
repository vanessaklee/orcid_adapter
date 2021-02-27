defmodule Adapter.Repo.Migrations.AddOrcidTable do
  use Ecto.Migration

  def change do
    create table(:orcid) do
      add :pid, :string
      add :orcid, :string
      add :external_ids, {:array, :map}
      add :family_name, :string
      add :given_names, :string
      add :credit_name, :string
      add :keywords, {:array, :map}
      add :other_names, {:array, :map}
    end
  end
end
