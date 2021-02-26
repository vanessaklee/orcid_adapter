defmodule OrcidAdapter.Orcid do
  import SweetXml
  import Ecto.Query
  alias OrcidAdapter.Repo

  def get(id) do
    token = Application.get_env(:orcid_adapter, :orcid_token)
    headers = [
      {"Accept", "application/vnd.orcid+xml"},
      {"Authorization", "Bearer #{token}"},
    ]
    url = "https://api.orcid.org/v3.0/#{id}/record"
    {:ok, resp} = HTTPoison.get(url, headers, [timeout: :infinity, recv_timeout: :infinity])
    resp.body
  end

  def details(record) do
    list = record |> xpath(~x"//person:person"l)

    Enum.map(list, fn l ->
      given_names = l |> xpath(~x"//person:name/personal-details:given-names/text()") || ""
      family_name = l |> xpath(~x"//person:name/personal-details:family-name/text()") || ""
      credit_name = l |> xpath(~x"//person:name/personal-details:credit-name/text()"s) || ""

      external_identifier_list = l |> xpath(~x"//external-identifier:external-identifiers/external-identifier:external-identifier"l) || []
      external_identifiers = Enum.map(external_identifier_list, fn ei ->
        source = ei |> xpath(~x"//common:source/common:source-name/text()"s) || ""
        type = ei |> xpath(~x"//common:external-id-type/text()"s) || ""
        id = ei |> xpath(~x"//common:source/common:external-id-value/text()"s) || ""
        id = if id == "" do
          ei |> xpath(~x"//common:external-id-value/text()"s) || ""
        else
          id
        end
        %{
          source: source,
          type: type,
          id: id
        }
      end)

      other_names_list = l |> xpath(~x"//other-name:other-names/other-name:other-name"l) || []
      other_names = Enum.map(other_names_list, fn ei ->
        ei |> xpath(~x"//other-name:content/text()"s)
      end) || []

      keyword_list = l |> xpath(~x"//keyword:keywords/keyword:keyword"l) || []
      keywords = Enum.map(keyword_list, fn kw ->
        kw |> xpath(~x"//keyword:content/text()"s)
      end) || []

      %{
        given_names: given_names,
        family_name: family_name,
        credit_name: credit_name,
        other_names: other_names,
        keywords: keywords,
        external_identifiers: external_identifiers
      }
    end)
  end

  def save(orc_id, pid, record) do
    personal_details = Map.get(record, :personal_details)
    Enum.each(personal_details, fn pd ->
      orcid = %OrcidAdapter.Schemas.Orcid{
        orcid: orc_id,
        pid: pid,
        external_ids: Map.get(pd, :external_identifiers),
        family_name: to_string(Map.get(pd, :family_name)),
        given_names: to_string(Map.get(pd, :given_names)),
        keywords: Map.get(pd, :keywords),
        other_names: Map.get(pd, :other_names),
        credit_name: Map.get(pd, :credit_name),
      }
      Repo.insert(orcid,
      on_conflict: :nothing)
    end)
    orc_id
  end
end
