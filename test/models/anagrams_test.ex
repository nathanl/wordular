# TODO - why isn't this file run if I do `mix test test/models/` but is if I specify the file?
defmodule Wordular.AnagramsTest do
  use ExUnit.Case, async: true

  test "knows the anagrams for 'bat'" do
    assert Anagrams.for("bat") == ["bat", "tab"]
  end

end
