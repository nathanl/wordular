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

  test "can convert a string to sorted codepoints" do
    assert Anagrams.sorted_codepoints("nappy") == ["a", "n", "p", "p", "y"]
  end

  test "can map dictionary words by character list" do
    actual = Anagrams.processed_dictionary(["bat", "tab", "hat"])
    expected = %{
      ["a", "b", "t"] => ["bat", "tab"],
      ["a", "h", "t"] => ["hat"],
    }
    assert actual == expected
  end

  test "is awesome!!! oh yayer" do
    IO.puts Anagrams.find_entry_sets_for(
      Anagram.sorted_codepoints("racecar"), 
      ["race", "car", "are"] |> Enum.into(HashSet.new, fn x -> Anagram.sorted_codepoints(x) end )
    )
  end

  # test "can find dictionary matches for an empty phrase" do
  #   dictionary = %{
  #     ["a", "b", "t"] => ["bat", "tab"],
  #     ["a", "h", "t"] => ["hat"],
  #   }
  #
  #   actual = Anagrams.matches_for([], dictionary)
  #   assert actual == dictionary
  # end
  #
  # test "can find dictionary matches for a non-empty phrase" do
  #   dictionary = %{
  #     ["a", "b", "t"] => ["bat", "tab"],
  #     ["a", "h", "t"] => ["hat"],
  #     ["m", "y"]      => ["my"],
  #   }
  #   expected = %{
  #     ["a", "b", "t"] => ["bat", "tab"],
  #     ["a", "h", "t"] => ["hat"],
  #   }
  #   actual = Anagrams.matches_for(["a", "a", "b", "h", "t", "t"], dictionary)
  #   assert actual == expected
  # end
  #
  # test "can remove one list from another" do
  #   assert Anagrams.without(["a", "b", "c"], ["a", "b"]) == ["c"]
  #   assert Anagrams.without(["b", "b", "c"], ["b", "c"]) == ["b"]
  #   assert Anagrams.without(["b", "b", "c"], ["c"])      == ["b", "b"]
  #   assert Anagrams.without(["a", "b", "c"], ["a", "a"]) == nil
  #   assert Anagrams.without(["a", "b", "c"], ["a", "q"]) == nil
  # end


end
