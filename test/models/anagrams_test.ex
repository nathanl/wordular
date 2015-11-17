# TODO - why isn't this file run if I do `mix test test/models/` but is if I specify the file?
defmodule Wordular.AnagramsTest do
  use ExUnit.Case, async: true

  test "knows the anagrams for 'bat'" do
    assert Anagrams.for("bat") == ["bat", "tab"]
  end

  test "can generate anagrams with spaces" do
    assert "be at" in Anagrams.for("beat")
    assert "a bet" in Anagrams.for("beat")
  end

  test "can make some permutations" do
    assert Anagrams.permutations(["a", "b"]) == [["a", "b"], ["b", "a"]]
  end 

  test "can permutate an empty list" do
    assert Anagrams.permutations([]) == [[]]
  end

  test "can convert a string to a character_list" do
    assert Anagrams.character_list("nappy") == ["a", "n", "p", "p", "y"]
  end

  test "can map dictionary words by character list" do
    actual = Anagrams.character_list_map(["bat", "tab", "hat"])
    expected = %{
      ["a", "b", "t"] => ["bat", "tab"],
      ["a", "h", "t"] => ["hat"],
    }
    assert actual == expected
  end

  test "can find dictionary matches for an empty phrase" do
    dictionary = %{
      ["a", "b", "t"] => ["bat", "tab"],
      ["a", "h", "t"] => ["hat"],
    }

    actual = Anagrams.matches_for([], dictionary)
    assert actual == dictionary
  end

  test "can find dictionary matches for a non-empty phrase" do
    dictionary = %{
      ["a", "b", "t"] => ["bat", "tab"],
      ["a", "h", "t"] => ["hat"],
      ["m", "y"]      => ["my"],
    }
    expected = %{
      ["a", "b", "t"] => ["bat", "tab"],
      ["a", "h", "t"] => ["hat"],
    }
    actual = Anagrams.matches_for(["a", "a", "b", "h", "t", "t"], dictionary)
    assert actual == expected
  end

  test "can remove one list from another" do
    assert Anagrams.remainder(["a", "b", "c"], ["a", "b"]) == ["c"]
    assert Anagrams.remainder(["b", "b", "c"], ["b", "c"]) == ["b"]
    assert Anagrams.remainder(["b", "b", "c"], ["c"])      == ["b", "b"]
    assert Anagrams.remainder(["a", "b", "c"], ["a", "a"]) == nil
    assert Anagrams.remainder(["a", "b", "c"], ["a", "q"]) == nil
  end


end
