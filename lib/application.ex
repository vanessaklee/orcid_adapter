defmodule OrcidAdapter.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      OrcidAdapter.Repo
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Exida.Supervisor)
  end
end
