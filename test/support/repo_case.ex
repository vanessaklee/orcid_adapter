defmodule OrcidAdapter.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias OrcidAdapter.Repo

      import Ecto
      import Ecto.Query
      import OrcidAdapter.RepoCase

      alias OrcidAdapter.Utils
      alias OrcidAdapter.Schemas.{Orcid, OrcidEducation, OrcidEmployment, OrcidPublications}
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(OrcidAdapter.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(OrcidAdapter.Repo, {:shared, self()})
    end

    :ok
  end
end
