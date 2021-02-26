defmodule OrcidAdapterTest do
  use OrcidAdapter.RepoCase
  alias OrcidAdapter.Repo
  alias OrcidAdapter.Schemas.{Orcid, OrcidEducation, OrcidEmployment, OrcidPublications}
  doctest OrcidAdapter

  @orcid_id "0000-0002-5572-8352" # Vanessa Lee test account

  test "query by institution returns results" do
    records = OrcidAdapter.query(:institution, "Interfolio")

    assert Enum.count(records) > 0
    assert Enum.any?(records, fn record -> Enum.any?(record.employment, fn e -> e.affiliation == 'Interfolio' end) end)
  end

  test "query by id returns result" do
    record = OrcidAdapter.query(@orcid_id)
    map = OrcidAdapter.map_record(@orcid_id, record)
    [ names | _ ] = map.personal_details

    assert names.family_name == 'Lee'
    assert names.given_names == 'Vanessa'
  end

  test "query by id can be saved" do
    record = OrcidAdapter.query(@orcid_id)
    map = OrcidAdapter.map_record(@orcid_id, record)
    OrcidAdapter.save(map, "1")

    orcid = Repo.get_by(Orcid, orcid: @orcid_id)
    assert orcid.family_name == "Lee"
    orcid_education = Repo.get_by(OrcidEducation, orcid: @orcid_id)
    assert orcid_education.end_date == 1997
    orcid_employment = Repo.get_by(OrcidEmployment, orcid: @orcid_id)
    assert orcid_employment.affiliation == "Interfolio"
    orcid_publication = Repo.get_by(OrcidPublications, orcid: @orcid_id)
    assert orcid_publication.type == "journal-article"
  end

  test "string converst to integer" do
    assert OrcidAdapter.to_integer("1776") == 1776
  end
end
