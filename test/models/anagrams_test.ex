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

  test "can find 'raw' anagrams (the unique lists of letters that can be pulled from the phrase)" do
    result = Anagrams.find_entry_sets_for(
      Anagrams.sorted_codepoints("racecar"), 
      ["race", "car", "are"] |> Enum.into(HashSet.new, fn x -> Anagrams.sorted_codepoints(x) end )
    )
    one_anagram = [Anagrams.sorted_codepoints("race"), Anagrams.sorted_codepoints("car")] |> Enum.into(HashSet.new)
    all_anagrams = Set.put(HashSet.new, one_anagram)
    assert result == all_anagrams
  end

  test "handles duplicated words in anagram result" do
    result = Anagrams.find_entry_sets_for(
      Anagrams.sorted_codepoints("apple apple racecar"), 
      ["race", "car", "apple"] |> Enum.into(HashSet.new, fn x -> Anagrams.sorted_codepoints(x) end )
    )
    # The problem is that we were thinking an anagram would never have duplicate words, so we defined an anagram
    # as a Set of sorted_codepoints.  It should have been a List of sorted_codepoints.  TODO: change that throughout the code.
    one_anagram = [Anagrams.sorted_codepoints("race"), Anagrams.sorted_codepoints("car"), Anagrams.sorted_codepoints("apple"),
                   Anagrams.sorted_codepoints("apple") ]
    all_anagrams = Set.put(HashSet.new, one_anagram)
    assert result == all_anagrams

  end

  test "subtractable_from?" do
    assert Anagrams.subtractable_from?(["a", "b"], ["a", "b", "c"]) == true
    assert Anagrams.subtractable_from?(["a", "b", "d"], ["a", "b", "c"]) == false
    assert Anagrams.subtractable_from?(["a", "b", "d"], ["a", "d"]) == false
    assert Anagrams.subtractable_from?([], ["a", "d"]) == true
    assert Anagrams.subtractable_from?(["a", "b", "d"], []) == false
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
