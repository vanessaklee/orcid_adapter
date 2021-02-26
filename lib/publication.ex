defmodule OrcidAdapter.Publication do
  import SweetXml
  alias OrcidAdapter.Repo

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

  def save(orc_id, pid, record) do
    works = Map.get(record, :work)
    Enum.each(works, fn wk ->
      y = to_string(Map.get(wk, :year))
      year = if y, do: OrcidAdapter.to_integer(y), else: nil
      pubs = %OrcidAdapter.Schemas.OrcidPublications{
        orcid: orc_id,
        pid: pid,
        external_ids: Map.get(wk, :external_identifiers),
        journal: to_string(Map.get(wk, :journal)),
        source: to_string(Map.get(wk, :source)),
        title: to_string(Map.get(wk, :title)),
        type: to_string(Map.get(wk, :type)),
        year: year,
      }
      Repo.insert(pubs,
      on_conflict: :nothing)
    end)
    orc_id
  end
end
