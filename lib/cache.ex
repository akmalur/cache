defmodule Cache do
  @moduledoc """
  A simple implementation of a recently used cache. Not intended for production use.
  """

  defstruct capacity: 0, store: %{}, usage: []

  @doc """
    Creates a new cache of specified `capacity`

    ## Examples

      iex> Cache.new(3)
      %Cache{capacity: 3, store: %{}, usage: []}

  """
  def new(capacity) when is_integer(capacity) do
    %Cache {capacity: capacity, store: %{}, usage: []}
  end

  @doc """
    Stores the given `value` under `key` in `cache`

    ## Examples

      iex> c = Cache.new(3)
      iex> Cache.store(c, "a", 1)
      %Cache{capacity: 3, store: %{"a" => 1}, usage: ["a"]}

      iex> c = Cache.new(2)
      iex> c = Cache.store(c, "a", 1)
      iex> c = Cache.store(c, "b", 2)
      iex> Cache.store(c, "c", 3)
      %Cache{capacity: 2, store: %{"b" => 2, "c" => 3}, usage: ["b", "c"]}

  """
  def store(%Cache{} = cache, key, value) do
    evict(cache, key)
    |> add(key, value)
    |> update_usage(key)
  end

  @doc """
    Get a value for a specific `key` in `map`.

    ## Examples

      iex> c = Cache.new(2)
      iex> c = Cache.store(c, "a", 1)
      iex> Cache.load(c, "a")
      {%Cache{capacity: 2, store: %{"a" => 1}, usage: ["a"]}, 1}

      iex> c = Cache.new(2)
      iex> c = Cache.store(c, "a", 1)
      iex> c = Cache.store(c, "b", 2)
      iex> Cache.load(c, "a")
      {%Cache{capacity: 2, store: %{"a" => 1, "b" => 2}, usage: ["b", "a"]}, 1}

  """
  def load(%Cache{} = cache, key) do
    case read(cache, key) do
      {c, v} when v == nil -> {c, v}
      {c, v} -> {update_usage(c, key), v}
    end
  end

  @doc """
    Deletes the entry in `cache` for a specific `key`

    ## Examples
      iex> c = Cache.new(2)
      iex> c = Cache.store(c, "a", 1)
      iex> Cache.delete(c, "a")
      %Cache{capacity: 2, store: %{}, usage: []}

  """
  def delete(%Cache{} = cache, key) do
    Map.put(cache, :usage, List.delete(cache.usage, key))
    |> Map.put(:store, Map.delete(cache.store, key))
  end

  defp read(cache, key) do
    {cache, Map.get(cache.store, key)}
  end

  defp add(cache, key, value) do
    Map.put(cache, :store, Map.put(cache.store, key, value))
  end

  defp update_usage(cache, key) do
    Map.put(cache, :usage, key_used(cache.usage, key))
  end

  defp evict(cache, key) do
    cond do
      Enum.member?(Map.keys(cache.store), key) ->
        cache
      (length(Map.keys(cache.store)) == cache.capacity) ->
        delete(cache, List.first(cache.usage))
      true -> cache
    end
  end

  defp key_used(usage, key) do
    usage = case Enum.member?(usage, key) do
      true -> for used_key <- usage, used_key !== key, do: used_key
      false -> usage
    end
    usage ++ [key]
  end
end
