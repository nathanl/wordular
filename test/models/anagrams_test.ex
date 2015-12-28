# TODO - why isn't this file run if I do `mix test test/models/` but is if I specify the file?
defmodule Wordular.AnagramsTest do
  use ExUnit.Case, async: true

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
    IO.puts("SKIPPING A TEST")
    # hr_dict = Anagrams.load_human_readable_dictionary("/usr/share/dict/words")
    # # results = Anagrams.for2("racecars are rad", hr_dict)
    # results = Anagrams.for2("racecar", hr_dict)
    # IO.inspect(Enum.take(results, 20))
  end

end
