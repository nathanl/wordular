# TODO - why isn't this file run if I do `mix test test/models/` but is if I specify the file?
defmodule Wordular.AnagramsTest do
  use ExUnit.Case, async: true

  test "can find human-readable anagrams of a phrase using a dictionary" do
    result = Anagrams.for("racecar", ["arc", "are", "car", "care", "race"])
    assert result == ["arc care", "arc race", "car care", "car race"]
  end

  test "can handle duplicate words in the input phrase" do
    result = Anagrams.for("apple racecar apple", ["race", "car", "apple"])
    assert result == ["apple apple car race"]
  end

  @tag timeout: 60000, big: true, slow: true
  test "a big ol realistic test" do
    hr_dict = Anagrams.load_human_readable_dictionary("/usr/share/dict/words")
    # hr_dict = Anagrams.load_human_readable_dictionary("/tmp/words") # remove words < 3 chars long, except "a"
    # hr_dict = Anagrams.load_human_readable_dictionary("/Users/nathanlong/code/wordular/tmp/possible_dictionary.txt")

    IO.puts "loaded the dictionary file"
    # results = Anagrams.for("racecars are rad", hr_dict)
    results = Anagrams.for("racecars are rad", hr_dict)
    # results = Anagrams.for("matthew wildeboer", hr_dict) # bogs down
    IO.inspect results
    IO.inspect("result count: #{Enum.count(results)}")
    # IO.inspect(Enum.max_by(results, fn(str) -> String.codepoints(str) |> Enum.filter(&(&1 == " ")) |> Enum.count end))
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

  test "subtractable_from?" do
    assert Anagrams.subtractable_from?(["a", "b"], ["a", "b", "c"]) == true
    assert Anagrams.subtractable_from?(["a", "b", "d"], ["a", "b", "c"]) == false
    assert Anagrams.subtractable_from?(["a", "b", "d"], ["a", "d"]) == false
    assert Anagrams.subtractable_from?([], ["a", "d"]) == true
    assert Anagrams.subtractable_from?(["a", "b", "d"], []) == false
  end

  test "human_readable builds a 'cartesian join' of words the letterbags can spell" do
    anagram = [["a","c","e","r"], ["a","c","r"]]
    dictionary = %{
      ["a", "c", "e", "r"] => ["race", "care"],
      ["a", "c", "r"] => ["car"],
    }
    assert((Anagrams.human_readable(anagram, dictionary) |> Enum.sort) == [
      "car care", "car race"
    ])
  end

end
