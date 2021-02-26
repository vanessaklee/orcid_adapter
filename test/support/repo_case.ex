defmodule OrcidAdapter.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias MyApp.Repo

      import Ecto
      import Ecto.Query
      import OrcidAdapter.RepoCase

      # and any other stuff
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
