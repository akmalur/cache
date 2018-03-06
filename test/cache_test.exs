defmodule User do defstruct [:id, :name] end

defmodule CacheTest do
  use ExUnit.Case
  doctest Cache

  test "can store a struct as value" do
    c = Cache.new(2)
    |> Cache.store("u", %User{})

    assert c == %Cache{capacity: 2, store: %{"u" => %User{id: nil, name: nil}}, usage: ["u"]}
  end
end
