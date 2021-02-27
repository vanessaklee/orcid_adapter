defmodule Adapter.Repo.Migrations.AddOrcidEducationTable do
  use Ecto.Migration

  def change do
    create table(:orcid_education) do
      add :orcid, :string
      add :pid, :string
      add :affiliation, :string
      add :department, :string
      add :role, :string
      add :start_date, :integer
      add :end_date, :integer
    end
  end
end
