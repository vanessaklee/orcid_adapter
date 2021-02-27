defmodule OrcidAdapter.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Adapter.Repo
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: OrcidAdapter.Supervisor)
  end
end
