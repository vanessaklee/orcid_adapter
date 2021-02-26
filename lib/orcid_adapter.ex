defmodule OrcidAdapter do
  @moduledoc """
  Instantiate queries to OrcID.
  """
  alias OrcidAdapter.{Orcid, Employment, Education, Publication, Affiliation, Utils}

  @spec query(Atom.t(), String.t()) :: list()
  @doc """
  Query OrcID for an institution.
  """
  def query(:institution, name) do
    query_all_for_affiliation(name)
    |> save(nil)
  end

  @spec query(String.t()) :: String.t()
  @doc """
  Query OrcID for a single id.
  """
  def query(id) do
    Orcid.get(id)
  end

  @spec query_all_for_affiliation(String.t()) :: list()
  @doc """
  Query OrcID for all ids associated with an affiliation.
  """
  def query_all_for_affiliation(affiliation) do
    ids = Affiliation.fetch_ids(affiliation, 0, 999)
    Enum.map(ids, fn id ->
      record = Orcid.get(id)
      map_record(id, record)
    end)
    |> List.flatten()
  end

  @spec lookup(String.t()) :: list()
  @doc """
  Lookup an orcid record by pid.
  """
  def lookup(pid) do
    personal_details = Orcid.lookup(pid)
    education = Education.lookup(pid)
    employment = Employment.lookup(pid)
    publications = Publication.lookup(pid)

    edu_emp = %{
      affiliations: (employment.affiliation ++ education.affiliation) |> Utils.flatten_and_filter(),
      departments: (employment.department ++ education.department) |> Utils.flatten_and_filter(),
      dates: (employment.dates ++ education.dates) |> Utils.flatten_and_filter() |> Enum.sort(),
      education_began: education.dates |> Enum.sort() |> List.first()
    }

    Map.merge(Map.merge(personal_details, edu_emp), publications)
  end

  @spec save(list(), String.t()) :: list() | String.t()
  @doc """
  Save OrcID records.
  """
  def save([], _pid), do: nil
  def save(nil, _pid), do: nil
  def save(records, pid) when is_list(records) do
    Enum.each(records, fn record ->
      save(record, pid)
    end)
    records
  end
  def save(record, pid) do
    orc_id = to_string(record.id)

    orc_id
    |> Orcid.save(pid, record)
    |> Education.save(pid, record)
    |> Employment.save(pid, record)
    |> Publication.save(pid, record)
    :ok
  end

  @spec map_record(String.t(), map()) :: map()
  @doc """
  Map OrcID result record to db schema.
  """
  def map_record(id, record) do
    %{
      id: id,
      personal_details: Orcid.details(record),
      education: Education.details(record),
      employment: Employment.details(record),
      work: Publication.details(record)
    }
  end
end
