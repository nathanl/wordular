# I want to write a fast anagram generator. But first I want to try the simplest thing that could possibly work: take a string, generate every possible rearrangement of its characters, and see if the resulting strings are all words in a dictionary. The "every possible rearrangement" part is O(N!), so that's horrible. But - baby steps.
defmodule Anagrams do

  def for(phrase) do
    phrase
    |> String.downcase
    |> rearrangements_of
    |> Enum.filter(&consists_of_words?(&1))
  end

  def rearrangements_of(phrase) do
    String.codepoints(phrase)
    |> permutations
    |> Enum.flat_map(&every_possible_spacing(&1))
    |> Enum.map(&Enum.join(&1, ""))
    |> Enum.uniq
  end

  def permutations([]) do
    [[]]
  end

  def permutations(list) do
    for h <- list, t <- permutations(list -- [h]), do: [h | t]
  end

  def every_possible_spacing([x]) do
    [[x]]
  end

  def every_possible_spacing([head | tail]) do
    tail_spaces = every_possible_spacing(tail)
    a = Enum.map(tail_spaces, fn(x) -> [head | x] end)
    b = Enum.map(tail_spaces, fn(x) -> [head | [" " | x]] end)
    a ++ b
  end

  def consists_of_words?(phrase) do
    phrase |> String.split |> Enum.all?(&is_a_word?(&1))
  end

  def is_a_word?(possible_word) do
    possible_word in dictionary
  end

  def dictionary do
    # NOTE: should always be downcased
    ["bat", "tab", "cat", "be", "at", "a", "bet"]
  end

end
