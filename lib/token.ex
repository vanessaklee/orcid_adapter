defmodule OrcidAdapter.Token do
  @moduledoc """
  Methods to manage the OrcID Token.
  """

  @doc """
  Query OrcID for a new token.
  """
  def new() do
    client_id = Application.get_env(:orcid_adapter, :orcid_client_id)
    client_secret = Application.get_env(:orcid_adapter, :orcid_client_secret)

    headers = [{"Accept", "application/json"}]
    url = "https://pub.orcid.org/oauth/token"
    body = Jason.encode!(%{
      client_id: client_id,
      client_secret: client_secret,
      scope: "/read-public",
      grant_type: "client_credentials"
    })
    _token = HTTPoison.post(url, body, headers, [timeout: :infinity, recv_timeout: :infinity])
  end
end
