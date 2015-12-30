# NOTE: see anagrams_ideas.md
defmodule Anagrams do

  # Top level function
  # phrase is a string
  # human_readable_dictionary is a set of strings
  def for(phrase, human_readable_dictionary) do
    dict          = dictionary(human_readable_dictionary)
    IO.puts "parsed the dictionary"
    dict_entries  = Map.keys(dict) |> Enum.into(HashSet.new)
    {anagrams, _} = anagrams_for(letterbag(phrase), dict_entries, %{})
    anagrams |> Enum.map(&human_readable(&1, dict)) |> List.flatten
  end

  # Takes a filename, returns list with one string per non-empty line
  def load_human_readable_dictionary(filename) do
    {:ok, file_contents} = File.read(filename)
    file_contents
    |> String.split("\n")
    |> Enum.map(&String.strip(&1))
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

  def dictionary(human_readable_dictionary) do
    dictionary(human_readable_dictionary, %{})
  end

  defp dictionary([], output_dict) do
    output_dict
  end

  # returns map with entries like ["d", "g", "o"] => ["god", "dog"]
  defp dictionary([current_word | remaining_words], output_dict) do
    entry_letterbag = letterbag(current_word)
    if Map.has_key?(output_dict, entry_letterbag) do
      existing_entry = Map.get(output_dict, entry_letterbag)
      updated_dict = Map.put(output_dict, entry_letterbag, existing_entry ++ [current_word])
    else
      updated_dict = Map.put(output_dict, entry_letterbag, [current_word])
    end
    dictionary(remaining_words, updated_dict)
  end

  # define base case
  # TODO - can I somehow match this and call it "empty phrase" for clarity?
  defp anagrams_for([], _dict_entries, memoization_dict) do
    {Set.put(HashSet.new, []), memoization_dict}
  end

  # catbat
  # set(set(["a", "b", "t"], ["a", "c", "t"]), ...)
  # phrase is a letterbag; dict_entries is a set of letterbag
  # return a set of entry sets - each entry set is a set of entries, each
  # entry is a letterbag, each entry set contains exactly the letters
  # of the input phrase
  # dict_entries is an enumerable.
  # returns a Set.
  defp anagrams_for(phrase, dict_entries, memoization_dict) do
    if Map.has_key?(memoization_dict, phrase) do
      {memoization_dict[phrase], memoization_dict}
    else
      usable_entries = usable_entries_for(dict_entries, phrase)

      if Enum.count(usable_entries) == 0 do
        {HashSet.new, memoization_dict}
      else
        # TODO - Enum.sort is general-purpose but we are actually putting one item into an already-sorted list, maybe can do it faster? Then again, the existing anagram is probably < 10 words long...
        # Also, letterbags are sorted so -- is less efficient than we could do this (or maybe we could use a hash of counters)
        #   x = for entry <- usable_entries, anagram <- anagrams_for(phrase -- entry, usable_entries, memoization_dict), do: Enum.sort([ entry | anagram ])
        #   x |> Enum.into(HashSet.new)
        # end

        z = Enum.reduce(usable_entries, %{answers: [], mdict: memoization_dict}, fn(entry, acc) ->
          {anagrams, memoization_dict} = anagrams_for((phrase |> without(entry)), usable_entries, acc.mdict)
          y = for anagram <- anagrams do
            Enum.sort([ entry | anagram ])
          end
          %{answers: (acc[:answers] ++ y), mdict: memoization_dict}
        end)

        x = z.answers |> Enum.into(HashSet.new)
        mmm = z.mdict

      {x, Map.put(mmm, phrase, x)}
    end

    end

  end

  def human_readable([], _dictionary) do
    []
  end

  def human_readable([ letterbag ], dictionary) do
    dictionary[letterbag]
  end

  # Convert a list of letterbags to a list of human-readable anagrams
  # e.g. [ letterbag("race"), letterbag("car") ] =>
  # [ "race car", "care car" ]
  def human_readable(anagram, dictionary) do
    [head | tail] = anagram
    hr_anagrams = human_readable(tail, dictionary)
    output = for hr_word <- dictionary[head], hr_anagram <- hr_anagrams do
      Enum.sort([hr_word, hr_anagram]) |> Enum.join(" ")
    end
    Enum.sort(output)
  end

  def usable_entries_for(dict_entries, phrase) do
    for entry <- dict_entries, subtractable_from?(entry, phrase), do: entry
  end

  def subtractable_from?(needles, haystack) do
    thing = haystack |> without(needles)
    expected_length = Enum.count(haystack) - Enum.count(needles)
    expected_length == Enum.count(thing)
  end

  # Takes two letterbags, subtracts one from the other
  # TODO - implement more efficiently since we know that these are sorted?
  def without(haystack, needles) do
    haystack -- needles
  end

end
