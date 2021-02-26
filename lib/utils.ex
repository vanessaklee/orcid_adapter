defmodule OrcidAdapter.Utils do
  @moduledoc """
  Module for utilities used across methods.
  """

  @spec to_integer(String.t()) :: Integer.t()
  @doc """
  Convert a string to integer. Used for years.
  """
  def to_integer(nil), do: nil
  def to_integer(""), do: nil
  def to_integer(str), do: String.to_integer(str)

  @spec flatten_and_filter(list()) :: list()
  @doc """
  Flatten a list, filter out nil values and empty strings, and return a list of unique items.
  """
  def flatten_and_filter(list) when is_list(list) do
    list
    |> List.flatten()
    |> Enum.filter(&(!is_nil(&1)))
    |> Enum.reject(fn x -> x == "" end)
    |> Enum.uniq()
  end
  def flatten_and_filter(notlist), do: notlist
end
