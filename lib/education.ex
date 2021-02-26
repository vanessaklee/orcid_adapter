defmodule OrcidAdapter.Education do
  import SweetXml
  import Ecto.Query
  alias OrcidAdapter.{Repo, Utils}
  alias OrcidAdapter.Schemas.OrcidEducation, as: EducationSchema

  @spec details(String.t()) :: map()
  @doc """
  Pull details from an XML response record and assign them to a map representing the data for education.
  """
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

  @spec lookup(String.t()) :: list()
  @doc """
  Lookup an record in the orcid_education table by pid.
  """
  def lookup(pid) do
    case Repo.all(where(EducationSchema, ^[pid: pid])) do
      [] -> nil
      edu ->
        Enum.reduce(edu, %{affiliation: [], department: [], dates: []}, fn e, acc ->
          affiliation = [e.affiliation, acc.affiliation]
            |> Utils.flatten_and_filter()
          department = [e.department, acc.department]
            |> Utils.flatten_and_filter()
          dates = [e.start_date, e.end_date, acc.dates]
            |> Utils.flatten_and_filter()
          %{
            affiliation: affiliation,
            department: department,
            dates: dates
          }
        end)
    end
  end

  @spec save(String.t(), String.t(), map()) :: String.t()
  @doc """
  Save OrcID record to orcid_education table.
  """
  def save(orc_id, pid, record) do
    educations = Map.get(record, :education)
    Enum.each(educations, fn ed ->
      s = to_string(Map.get(ed, :start_date))
      e = to_string(Map.get(ed, :end_date))
      start_year = if s, do: Utils.to_integer(s), else: nil
      end_year = if e, do: Utils.to_integer(e), else: nil
      education = %EducationSchema{
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
