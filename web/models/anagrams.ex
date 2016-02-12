# NOTE: see anagrams_ideas.md
defmodule Anagrams do

  # Top level function
  # phrase is a string
  # human_readable_dictionary is a set of strings
  def for(phrase, human_readable_dictionary) do
    {:ok, cache_pid} = Agent.start_link(fn -> %{} end)
    dict          = dictionary(human_readable_dictionary)
    dict_entries  = MapSet.new(Map.keys(dict))
    anagrams = anagrams_for(letterbag(phrase), dict_entries, cache_pid)
    anagrams |> Enum.map(&human_readable(&1, dict)) |> List.flatten
  end

  # Takes a filename, returns list with one string per non-empty line
  def load_human_readable_dictionary(filename) do
    File.stream!(filename)
    |> Enum.map(&String.strip/1)
    |> Enum.reject(&(&1 == ""))
  end

  # Sorted, non-unique list of codepoints
  # "alpha" -> ["a", "a", "h", "l", "p"]
  def letterbag(string) do
    string
    |> String.codepoints
    |> Enum.reject(&(&1 == " "))
    |> Enum.sort
  end

  # returns map with entries like ["d", "g", "o"] => ["god", "dog"]
  def dictionary(human_readable_dictionary) do
    Enum.reduce(human_readable_dictionary, %{}, fn word, map_acc ->
      # If key isn't found, the value passed to our function is 'nil'
      update_in(map_acc, [letterbag(word)], &((&1 || []) ++ [word]))
    end)
  end

  # define base case
  defp anagrams_for(empty_phrase = [], _dict_entries, _cache_pid) do
    MapSet.new([ empty_phrase ])
  end

  # catbat
  # set([["a", "b", "t"], ["a", "c", "t"]], ...)
  # phrase is a letterbag; dict_entries is a set of letterbag
  # return a set of answers - each answer is a list of letterbags,
  # each answer contains exactly the letters of the input phrase
  # dict_entries is an enumerable.
  # returns a Set.
  defp anagrams_for(phrase, dict_entries, cache_pid) do
    require Memoizer
    Memoizer.memoize phrase do
      x = 2
      IO.inspect phrase
      usable_entries = usable_entries_for(dict_entries, phrase)
      if usable_entries == [] do
        %MapSet{}
      else
        answers = for entry <- usable_entries,
        anagrams_without_this_entry = anagrams_for((phrase |> without(entry)), usable_entries, cache_pid),
        smaller_anagram <- anagrams_without_this_entry,
        do:  Enum.sort([entry | smaller_anagram])
        MapSet.new(answers)
      end
    end
  end

  # Convert a list of letterbags to a list of human-readable anagrams
  # e.g. [ letterbag("race"), letterbag("car") ] =>
  # [ "care car", "race car" ]
  def human_readable(anagram, dictionary) do
    anagram
    |> Enum.map(&(dictionary[&1]))
    |> cartesian_product
    |> Enum.map(&Enum.join(&1, " "))
    |> Enum.sort
  end

  # cartesian_prod([0..2, 0..1, 0..2]) = [000, 001, 002, 010, 011, 012, 100...]
  def cartesian_product([]), do: []
  def cartesian_product(lists) do
    Enum.reduce(lists, [ [] ], fn one_list, acc ->
      # New acc is: everything we've built so far, with every new option prepended
      for item <- one_list, subproduct <- acc, do: [item | subproduct]
    end)
  end

  def usable_entries_for(dict_entries, phrase) do
    Enum.filter(dict_entries, &(subtractable_from?(&1, phrase)))
  end

  def subtractable_from?(needles, haystack) do
    thing = haystack |> without(needles)
    # TODO: Enum.count(a_list) is O(n).  If the letterbags we passed around
    # were not sorted lists but a %Letterbag{sorted_letters: [...], size: 48}
    # we could make this O(1), and probably find other optimizations throughout
    # the code.
    expected_length = Enum.count(haystack) - Enum.count(needles)
    expected_length == Enum.count(thing)
  end

  # Takes two letterbags, subtracts one from the other
  # TODO - implement more efficiently since we know that these are sorted?
  def without(haystack, needles) do
    haystack -- needles
  end

end
