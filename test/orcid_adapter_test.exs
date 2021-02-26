defmodule OrcidAdapterTest do
  use OrcidAdapter.RepoCase
  doctest OrcidAdapter

  @orcid_id "0000-0003-3648-1494"

  test "query by id returns result" do
    record = OrcidAdapter.query(@orcid_id)
    map = OrcidAdapter.map_record(@orcid_id, record)
    [ names | _ ] = map.personal_details

    assert names.family_name == 'Apgar'
    assert names.given_names == 'Virginia'
  end

  test "string converst to integer" do
    assert OrcidAdapter.to_integer("1776") == 1776
  end
end
