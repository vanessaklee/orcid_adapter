defmodule OrcidAdapterTest do
  use OrcidAdapter.RepoCase
  doctest OrcidAdapter

  @orcid_id "0000-0002-5572-8352" # Vanessa Lee test account
  @family_name "Lee"
  @end_date 1997
  @affiliation "Interfolio"
  @pub_type "journal-article"
  @doi "10.1353/CHQ.0.1237"

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
    assert orcid.family_name == @family_name
    orcid_education = Repo.get_by(OrcidEducation, orcid: @orcid_id)
    assert orcid_education.end_date == @end_date
    orcid_employment = Repo.get_by(OrcidEmployment, orcid: @orcid_id)
    assert orcid_employment.affiliation == @affiliation
    orcid_publication = Repo.get_by(OrcidPublications, orcid: @orcid_id)
    assert orcid_publication.type == @pub_type
  end

  test "lookup orcid record by pid" do
    pid = "2"
    record = OrcidAdapter.query(@orcid_id)
    map = OrcidAdapter.map_record(@orcid_id, record)

    OrcidAdapter.save(map, pid)
    orcid = OrcidAdapter.lookup(pid)

    assert @family_name in orcid.last_names
    assert @end_date in orcid.dates
    assert @affiliation in orcid.affiliations
    assert @doi in orcid.dois
  end

  test "string converst to integer" do
    assert Utils.to_integer("1776") == 1776
  end
end
