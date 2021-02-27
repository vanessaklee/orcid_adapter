defmodule Adapter.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Adapter.Repo

      import Ecto
      import Ecto.Query
      import Adapter.RepoCase

      alias OrcidAdapter.Utils
      alias OrcidAdapter.Schemas.{Orcid, OrcidEducation, OrcidEmployment, OrcidPublications}
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Adapter.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Adapter.Repo, {:shared, self()})
    end

    :ok
  end
end
