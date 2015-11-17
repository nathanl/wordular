# The "every possible rearrangement" part is O(N!), so that's horrible. Adding
# all possible space positions is more horrible. This algorithm "works" for
# 6-letter input phrases but chokes on 7, and we still have a tiny
# dictionary. We should be able to ignore the order of the letters and spaces.
# Possible strategy:
# - Convert input phrase to letters and sort them (but don't use a set,
# because it's a non-unique list)
# - For each word in the dictionary, ask "are all of this word's letters
# contained in the phrase's letters?" (Again, this is not a set operation - if
# the word is "apple", the phrase must have two "p"s.) If so, subtract this
# word's letters from the phrase's letters and recurse with the smaller phrase
# and the list of words found so far. If we ever get down to an empty list of
# letters form the phrase  and a non-empty list of words, we've found an
# anagram. If we ever run out of words and still have letters from our phrase,
# we've hit a dead end.
# - While doing the above, if we fail to find a word, ensure that we don't
# look for it in the recursions. Eg, if we can't find "apple" in "racecars are
# rad", but we can find "are", there's no point looking for "apple" in
# "racecars rad". DO NOT remove "apple" from the dictionary if we DO find it -
# it may be in there again. Eg "apple apple, likes to grapple"
# - Dicationary words may also be anagrams of each other. Eg, if our phrase
# contains "bat", it contains "tab", because they are both examples of the
# letter list "abt". Pre-process our dictionary to group these, so that
# we can check for "abt" once and immediately know that any of its matching
# words can be made from the phrase.
# - If we can get all the above working, consider how to parallelize it
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
