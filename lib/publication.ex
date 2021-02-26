defmodule OrcidAdapter.Publication do
  import SweetXml
  import Ecto.Query
  alias OrcidAdapter.{Repo, Utils}
  alias OrcidAdapter.Schemas.OrcidPublications, as: PublicationSchema

  @spec details(String.t()) :: map()
  @doc """
  Pull details from an XML response record and assign them to a map representing the data for a publication.
  """
  def details(record) do
    list = record |> xpath(~x"//activities:activities-summary/activities:works/activities:group"l)

    Enum.map(list, fn l ->
      external_identifier_list = l |> xpath(~x"//common:external-ids/common:external-id"l) || []
      external_identifiers = Enum.map(external_identifier_list, fn ei ->
        type = ei |> xpath(~x"//common:external-id-type/text()"s) || ""
        id = ei |> xpath(~x"//common:external-id-value/text()"s) || ""
        %{
          type: type,
          id: id
        }
      end)

      source = l |> xpath(~x"//work:work-summary/common:source/common:source-name/text()") || ""
      title = l |> xpath(~x"//work:work-summary/work:title/common:title/text()") || ""
      type = l |> xpath(~x"//work:work-summary/work:type/text()") || ""
      year = l |> xpath(~x"//work:work-summary/common:publication-date/common:year/text()") || ""
      journal = l |> xpath(~x"//work:work-summary/work:journal-title/text()") || ""

      %{
        external_identifiers: external_identifiers,
        source: source,
        title: title,
        type: type,
        year: year,
        journal: journal
      }
    end)
  end

  @spec lookup(String.t()) :: list()
  @doc """
  Lookup an record in the orcid_publications table by pid.
  """
  def lookup(pid) do
    case Repo.all(where(PublicationSchema, ^[pid: pid])) do
      [] -> nil
      works ->
        Enum.reduce(works, %{dois: []}, fn w, _ ->
          external = w.external_ids
          dois = Enum.reduce(external, [], fn e, acc2 ->
            if Map.get(e, "type") == "doi" do
              List.insert_at(acc2, -1, Map.get(e, "id"))
            else
              acc2
            end
          end)
          %{
            dois: dois
          }
        end)
    end
  end

  @spec save(String.t(), String.t(), map()) :: String.t()
  @doc """
  Save OrcID record to orcid_publications table.
  """
  def save(orc_id, pid, record) do
    works = Map.get(record, :work)
    Enum.each(works, fn wk ->
      pubs = %PublicationSchema{
        orcid: orc_id,
        pid: pid,
        external_ids: Map.get(wk, :external_identifiers),
        journal: to_string(Map.get(wk, :journal)),
        source: to_string(Map.get(wk, :source)),
        title: to_string(Map.get(wk, :title)),
        type: to_string(Map.get(wk, :type)),
        year: to_string(Map.get(wk, :year)) |> Utils.to_integer() || nil
      }
      Repo.insert(pubs, on_conflict: :nothing)
    end)
    orc_id
  end
end
