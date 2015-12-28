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
    assert Anagrams.letterbag("nappy") == ["a", "n", "p", "p", "y"]
  end

  test "can map dictionary words by character list" do
    actual = Anagrams.dictionary(["bat", "tab", "hat"])
    expected = %{
      ["a", "b", "t"] => ["bat", "tab"],
      ["a", "h", "t"] => ["hat"],
    }
    assert actual == expected
  end

  test "can find 'raw' anagrams (the unique lists of letters that can be pulled from the phrase)" do
    result = Anagrams.anagrams_for(
      Anagrams.letterbag("racecar"), 
      ["are", "car", "race"] |> Enum.into(HashSet.new, fn x -> Anagrams.letterbag(x) end )
    )
    one_anagram = [Anagrams.letterbag("race"), Anagrams.letterbag("car")]
    all_anagrams = Set.put(HashSet.new, one_anagram)
    assert result == all_anagrams
  end

  test "handles duplicated words in anagram result" do
    result = Anagrams.anagrams_for(
      Anagrams.letterbag("apple apple racecar"), 
      ["race", "car", "apple"] |> Enum.into(HashSet.new, fn x -> Anagrams.letterbag(x) end )
    )
    # The problem is that we were thinking an anagram would never have duplicate words, so we defined an anagram
    # as a Set of letterbag.  It should have been a List of letterbag.  TODO: change that throughout the code.
    one_anagram = [Anagrams.letterbag("race"), Anagrams.letterbag("car"), Anagrams.letterbag("apple"),
                   Anagrams.letterbag("apple") ]
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

  test "human_readable" do
    anagram = [["a","c","e","r"], ["a","c","r"]]
    dictionary = %{
      ["a", "c", "e", "r"] => ["race", "care"],
      ["a", "c", "r"] => ["car"],
    }
    assert((Anagrams.human_readable(anagram, dictionary) |> Enum.sort) == [
      "care car", "race car"
    ])
  end

  @tag timeout: 40000
  test "a big ol realistic test" do
    hr_dict = Anagrams.load_human_readable_dictionary("/usr/share/dict/words")
    # results = Anagrams.for2("racecars are rad", hr_dict)
    results = Anagrams.for2("racecar", hr_dict)
    IO.puts "got results"
    IO.inspect(Enum.take(results, 2))
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
