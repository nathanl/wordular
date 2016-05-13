# NOTE: see anagrams_ideas.md
defmodule Anagrams do

  # Top level function
  # phrase is a string
  # human_readable_dictionary is a set of strings
  def for(phrase, human_readable_dictionary) do
    {:ok, cache_pid} = Agent.start_link(fn -> %{} end)
    dict          = dictionary(human_readable_dictionary)
    dict_entries  = MapSet.new(Map.keys(dict))
    anagrams = anagrams_for(alphagram(phrase), dict_entries, cache_pid)
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
  def alphagram(string) do
    string
    |> String.codepoints
    |> Enum.reject(&(&1 == " "))
    |> Enum.sort
  end

  # returns map with entries like ["d", "g", "o"] => ["god", "dog"]
  def dictionary(human_readable_dictionary) do
    Enum.reduce(human_readable_dictionary, %{}, fn word, map_acc ->
      # If key isn't found, the value passed to our function is 'nil'
      update_in(map_acc, [alphagram(word)], &([word|(&1 || [])]))
    end)
  end

  # define base case
  defp anagrams_for([], _dict_entries, _cache_pid) do
    MapSet.new([ [] ])
  end

  # catbat
  # set([["a", "b", "t"], ["a", "c", "t"]], ...)
  # phrase is a alphagram; dict_entries is a set of alphagrams
  # return a set of answers - each answer is a list of alphagrams,
  # each answer contains exactly the letters of the input phrase
  # dict_entries is an enumerable.
  # returns a Set.
  defp anagrams_for(phrase, dict_entries, cache_pid) do
    cached_result = Agent.get(cache_pid, fn map -> map[phrase] end)

    if cached_result != nil do
      cached_result
    else
      usable_entries = usable_entries_for(dict_entries, phrase)

      result = if usable_entries == [] do
        MapSet.new
      else

        answers = for entry <- usable_entries,
                      anagrams_without_this_entry = anagrams_for((phrase |> without(entry)), usable_entries, cache_pid),
                      smaller_anagram <- anagrams_without_this_entry,
                      do:  Enum.sort([entry | smaller_anagram])

        MapSet.new(answers)
      end

      Agent.update(cache_pid, fn map -> Map.put(map, phrase, result) end)
      result

    end

  end

  # Convert a list of alphagrams to a list of human-readable anagrams
  # e.g. [ alphagram("race"), alphagram("car") ] =>
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
    Enum.filter(dict_entries, &(sublist?(&1, phrase)))
  end

  def sublist?(possible_sublist, list) do
    thing = list |> without(possible_sublist)
    # TODO: Enum.count(a_list) is O(n).  If the alphagrams we passed around
    # were not sorted lists but a %alphagram{sorted_letters: [...], size: 48}
    # we could make this O(1), and probably find other optimizations throughout
    # the code.
    expected_length = Enum.count(list) - Enum.count(possible_sublist)
    expected_length == Enum.count(thing)
  end

  # Takes two alphagrams, subtracts one from the other
  # TODO - implement more efficiently since we know that these are sorted?
  def without(haystack, needles) do
    haystack -- needles
  end

end
