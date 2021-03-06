# TODO - why isn't this file run if I do `mix test test/models/` but is if I specify the file?
defmodule Wordular.AnagramsTest do
  use ExUnit.Case, async: true

  test "can find the only possible anagrams using a tiny dictionary" do
    result = Anagrams.for("onto", ["on", "to"])
    assert result == ["to on"]
  end

  test "ignores punctuation, capitalization and spaces" do
    result = Anagrams.for("On, To!", ["on", "to"])
    assert result == ["to on"]
  end

  test "can find human-readable anagrams of a phrase using a dictionary" do
    result = Anagrams.for("racecar", ["arc", "are", "car", "care", "race"])
    assert result == ["arc care", "arc race", "car care", "car race"]
  end

  test "can handle duplicate words in the input phrase" do
    result = Anagrams.for("apple racecar apple", ["race", "car", "apple", "racecar"])
    assert result == ["apple apple car race", "apple apple racecar"]
  end

  @tag skip: "perf test, big and slow, has big old output"
  @tag timeout: 120000, big: true, slow: true
  test "a big ol realistic test" do
    # hr_dict = Anagrams.load_human_readable_dictionary("/usr/share/dict/words")
    # hr_dict = Anagrams.load_human_readable_dictionary("/tmp/words") # remove words < 3 chars long, except "a"
    # use http://www-01.sil.org/linguistics/wordlists/english/wordlist/wordsEn.txt
    hr_dict = Anagrams.load_human_readable_dictionary("/Users/nathanl/code/wordular/tmp/sil_wordlist.txt")

    IO.puts "loaded the dictionary file"
    # results = Anagrams.for("racecars are rad", hr_dict)
    results = Anagrams.for("racecars are rad me lad", hr_dict)
    # results = Anagrams.for("matthew wildeboer", hr_dict) # bogs down
    IO.inspect results
    IO.inspect("result count: #{Enum.count(results)}")
    File.write!("tmp/results.txt", results) # TODO make it put one anagram per line
    # IO.inspect(Enum.max_by(results, fn(str) -> String.codepoints(str) |> Enum.filter(&(&1 == " ")) |> Enum.count end))
  end

  test "can convert a string to sorted codepoints" do
    assert Anagrams.alphagram("nappy") == ["a", "n", "p", "p", "y"]
  end

  test "can map dictionary words by character list" do
    actual = Anagrams.dictionary(["bat", "tab", "hat"])
    expected = %{
      ["a", "b", "t"] => ["tab", "bat"],
      ["a", "h", "t"] => ["hat"],
    }
    assert actual == expected
  end

  test "sub_alphagram?" do
    assert Anagrams.sub_alphagram?(["a"],           ["a", "b"])      == true
    assert Anagrams.sub_alphagram?(["b"],           ["a", "b"])      == true
    assert Anagrams.sub_alphagram?(["c"],           ["a", "b"])      == false
    assert Anagrams.sub_alphagram?(["a", "b"],      ["a", "b"])      == true
    assert Anagrams.sub_alphagram?(["a", "b"],      ["a", "g"])      == false
    assert Anagrams.sub_alphagram?(["a", "a"],      ["a", "b"])      == false
    assert Anagrams.sub_alphagram?(["a", "a"],      ["a", "a", "b"]) == true
    assert Anagrams.sub_alphagram?([],              ["a", "b"])      == true
    assert Anagrams.sub_alphagram?(["a", "b"],      [])              == false
  end

  test "human_readable builds a 'cartesian join' of words the alphagrams can spell" do
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
