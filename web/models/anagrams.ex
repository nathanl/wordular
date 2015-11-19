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

  def sorted_codepoints(string) do
    string
    |> String.codepoints
    |> Enum.sort
  end

  def processed_dictionary(dictionary) do
    processed_dictionary(dictionary, %{})
  end

  defp processed_dictionary([], output_pd) do
    output_pd
  end

  defp processed_dictionary([current_word | remaining_words], output_pd) do
    current_word_chars = sorted_codepoints(current_word)
    if Map.has_key?(output_pd, current_word_chars) do
      existing_entry = Map.get(output_pd, current_word_chars)
      updated_pd = Map.put(output_pd, current_word_chars, existing_entry ++ [current_word])
    else
      updated_pd = Map.put(output_pd, current_word_chars, [current_word])
    end
    processed_dictionary(remaining_words, updated_pd)
  end

  def for2(phrase, dictionary) do
    pd = processed_dictionary(dictionary)
    entry_sets = find_entry_sets_for(sorted_codepoints(phrase), Map.keys(pd) |> Enum.into(HashSet.new))
    # expand those into their possible anagrams
  end

  # define base case
  def find_entry_sets_for([], _dict_entries) do
    Set.put(HashSet.new, HashSet.new)
  end

  # catbat
  # set(set(["a", "b", "t"], ["a", "c", "t"]), ...)
  # phrase is a sorted_codepoints; dict_entries is a set of sorted_codepoints
  # return a set of entry sets - each entry set is a set of entries, each
  # entry is a sorted_codepoints, each entry set contains exactly the letters
  # of the input phrase
  def find_entry_sets_for(phrase, dict_entries) do
    usable_entries = usable_entries_for(dict_entries, phrase) # TODO define this
    if Set.size(usable_entries) == 0 do
      HashSet.new
    else
      x = for entry <- usable_entries, entry_set <- find_entry_sets_for( (without(phrase, entry)), usable_entries), do: entry_set.put(entry)
      x |> Enum.into(HashSet.new)
    end
  end

  # # success base case for recursion
  # def matches_for([], processed_dictionary) do
  #   processed_dictionary
  # end
  #
  # def matches_for(sorted_codepoints, processed_dictionary) do
  #   # for each word in the processed_dictionary, try subtracting
  #   # only the ones found in the top level phrase are possible to find in
  #   # sub-phrases...
  # end
  #
  # # TODO - maybe make this List.without
  # def without(haystack, needles) do
  # end

end
