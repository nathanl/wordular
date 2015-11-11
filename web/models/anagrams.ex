# I want to write a fast anagram generator. But first I want to try the simplest thing that could possibly work: take a string, generate every possible rearrangement of its characters, and see if the resulting strings are all words in a dictionary. The "every possible rearrangement" part is O(N!), so that's horrible. But - baby steps.
defmodule Anagrams do

  def for(phrase) do
    Enum.filter(rearrangements_of(phrase), &is_a_word?(&1))
  end

  def rearrangements_of(phrase) do
    String.split(phrase, "")
    |> permutations
    # |> Enum.shuffle
    # |> List.to_string
  end

  def permutations([]) do
    [[]]
  end

  def permutations(list) do
    dictionary
    # um... try to figure out http://www.erlang.org/doc/programming_examples/list_comprehensions.html#id64959
    # perms(list)  -> [[H|T] || H <- L, T <- perms(L--[H])].
  end

  def is_a_word?(possible_word) do
    Enum.any?(dictionary, fn(entry) -> entry == possible_word end)
  end

  def dictionary do
    ["bat", "tab"]
  end

end
