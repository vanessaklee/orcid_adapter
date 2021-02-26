defmodule OrcidAdapter.Affiliation do
  import SweetXml

  def fetch_ids(affiliation, 0, _) do
    token = Application.get_env(:orcid_adapter, :orcid_token)
    aff = URI.encode(affiliation)
    headers = [
      {"Accept", "application/vnd.orcid+xml"},
      {"Authorization", "Bearer #{token}"},
    ]
    url = "https://api.orcid.org/v3.0/expanded-search/?q=affiliation-org-name:#{aff}"
    {:ok, resp} = HTTPoison.get(url, headers, [ssl: [{:versions, [:'tlsv1.2']}], timeout: :infinity, recv_timeout: :infinity])

    doc = resp.body
    num_found =
      doc
      |> String.split("num-found=\"")
      |> List.last()
      |> String.split("\" xmlns:expanded-search=\"")
      |> List.first()
      |> String.to_integer()

    list = doc |> xpath(~x"//expanded-search:expanded-result"l)
    ids = Enum.map(list, fn l ->
      l |> xpath(~x"//expanded-search:orcid-id/text()")
    end)

    fetch_ids(ids, affiliation, num_found-1000, 1000, nil)
  end
  def fetch_ids(ids, affiliation, num_left, start, _) do
    token = Application.get_env(:orcid_adapter, :orcid_token)
    aff = URI.encode(affiliation)
    headers = [
      {"Accept", "application/vnd.orcid+xml"},
      {"Authorization", "Bearer #{token}"},
    ]
    url = if num_left < 1000 do
      "https://api.orcid.org/v3.0/expanded-search/?q=affiliation-org-name:#{aff}&start=#{start}&rows=#{num_left}"
    else
      "https://api.orcid.org/v3.0/expanded-search/?q=affiliation-org-name:#{aff}&start=#{start}"
    end
    {:ok, resp} = HTTPoison.get(url, headers, [timeout: :infinity, recv_timeout: :infinity])

    doc = resp.body
    # num_found =
    #   doc
    #   |> String.split("num-found=\"")
    #   |> List.last()
    #   |> String.split("\" xmlns:expanded-search=\"")
    #   |> List.first()
    #   |> String.to_integer()

    list = doc |> xpath(~x"//expanded-search:expanded-result"l)
    next_ids = Enum.map(list, fn l ->
      l |> xpath(~x"//expanded-search:orcid-id/text()")
    end)

    all_ids = ids ++ next_ids
    new_num_left = num_left-1000
    if new_num_left <= 0 do
      all_ids
    else
      fetch_ids(all_ids, affiliation, new_num_left, start + 1000, nil)
    end
  end
end
