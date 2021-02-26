defmodule OrcidAdapter.Education do
  import SweetXml
  alias OrcidAdapter.Repo

  def details(record) do
    list = record |> xpath(~x"//education:education-summary"l)

    Enum.map(list, fn l ->
      dept = l |> xpath(~x"//common:department-name/text()")
      role = l |> xpath(~x"//common:role-title/text()")
      institution = l |> xpath(~x"//common:organization/common:name/text()")
      start_date = l |> xpath(~x"//common:start-date/common:year/text()")
      end_date = l |> xpath(~x"//common:end-date/common:year/text()")
      %{
        affiliation: institution,
        department: dept,
        start_date: start_date,
        end_date: end_date,
        role: role
      }
    end)
  end

  def save(orc_id, pid, record) do
    educations = Map.get(record, :education)
    Enum.each(educations, fn ed ->
      s = to_string(Map.get(ed, :start_date))
      e = to_string(Map.get(ed, :end_date))
      start_year = if s, do: OrcidAdapter.to_integer(s), else: nil
      end_year = if e, do: OrcidAdapter.to_integer(e), else: nil
      education = %OrcidAdapter.Schemas.OrcidEducation{
        orcid: orc_id,
        pid: pid,
        affiliation: to_string(Map.get(ed, :affiliation)),
        department: to_string(Map.get(ed, :department)),
        role: to_string(Map.get(ed, :role)),
        start_date: start_year,
        end_date: end_year,
      }
      Repo.insert(education,
      on_conflict: :nothing)
    end)
    orc_id
  end
end
