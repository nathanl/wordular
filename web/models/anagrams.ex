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

  def letterbag(string) do
    string
    |> String.codepoints
    |> Enum.reject(fn (x) -> x == " " end)
    |> Enum.sort
  end

  def processed_dictionary(dictionary) do
    processed_dictionary(dictionary, %{})
  end

  defp processed_dictionary([], output_pd) do
    output_pd
  end

  # returns map with entries like ["d", "g", "o"] => ["god", "dog"]
  defp processed_dictionary([current_word | remaining_words], output_pd) do
    #"dog" -> ["d", "g", "o"] sorted codepoints
    current_word_chars = letterbag(current_word)
    #put sorted codepoints into map with "dog" as value.
    if Map.has_key?(output_pd, current_word_chars) do
      existing_entry = Map.get(output_pd, current_word_chars)
      updated_pd = Map.put(output_pd, current_word_chars, existing_entry ++ [current_word])
    else
      updated_pd = Map.put(output_pd, current_word_chars, [current_word])
    end
    processed_dictionary(remaining_words, updated_pd)
  end

  # Top level function
  # phrase is a string
  # dictionary is a set of strings
  def for2(phrase, dictionary) do
    pd = processed_dictionary(dictionary)
    dict_entries = Map.keys(pd) |> Enum.into(HashSet.new)
    anagrams = anagrams_for(letterbag(phrase), dict_entries)
    # TODO: expand those into their possible "human-readable" anagrams
  end

  # define base case
  def anagrams_for([], _dict_entries) do
    Set.put(HashSet.new, [])
  end

  # catbat
  # set(set(["a", "b", "t"], ["a", "c", "t"]), ...)
  # phrase is a letterbag; dict_entries is a set of letterbag
  # return a set of entry sets - each entry set is a set of entries, each
  # entry is a letterbag, each entry set contains exactly the letters
  # of the input phrase
  # dict_entries is an enumerable.
  # returns a Set.
  def anagrams_for(phrase, dict_entries) do
    usable_entries = usable_entries_for(dict_entries, phrase)
    if Enum.count(usable_entries) == 0 do
      HashSet.new
    else
      x = for entry <- usable_entries, anagram <- anagrams_for(phrase -- entry, usable_entries), do: Enum.sort([ entry | anagram ])
      x |> Enum.into(HashSet.new)
    end
  end

  def usable_entries_for(dict_entries, phrase) do
    # return a list comprehension that selects subtractable dudes
    for entry <- dict_entries, subtractable_from?(entry, phrase), do: entry
    # I think that's it.
  end

  def subtractable_from?(needles, haystack) do
    thing = haystack -- needles
    expected_length = Enum.count(haystack) - Enum.count(needles)
    expected_length == Enum.count(thing)
  end

    # for each entry in dict_entries,
    #  if we can subtract entry from phrase,
    #    keep it
    # return what we kept

  # # success base case for recursion
  # def matches_for([], processed_dictionary) do
  #   processed_dictionary
  # end
  #
  # def matches_for(letterbag, processed_dictionary) do
  #   # for each letterbag in the processed_dictionary, try subtracting
  #   # only the ones found in the top level phrase are possible to find in
  #   # sub-phrases...
  # end
  #

end
