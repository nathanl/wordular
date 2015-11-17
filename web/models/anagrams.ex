# NOTE: see anagrams_ideas.md
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

  def character_list(string) do
    string
    |> String.codepoints
    |> Enum.sort
  end

  def character_list_map(words) do
    p_character_list_map(words, %{})
  end

  defp p_character_list_map([], map) do
    map
  end

  defp p_character_list_map([current_word | remaining_words], map) do
    current_word_chars = character_list(current_word)
    if Map.has_key?(map, current_word_chars) do
      existing_entry = Map.get(map, current_word_chars)
      updated_map = Map.put(map, current_word_chars, existing_entry ++ [current_word])
    else
      updated_map = Map.put(map, current_word_chars, [current_word])
    end
    p_character_list_map(remaining_words, updated_map)
  end

  # success base case for recursion
  def matches_for([], dictionary) do
    dictionary
  end

  def matches_for(charlist, dictionary) do
    # for each word in the dictionary, try subtracting
    # only the ones found in the top level phrase are possible to find in
    # sub-phrases...
  end

  def remainder(haystack, needle) do
  end

end
