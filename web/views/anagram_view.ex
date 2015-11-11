defmodule Wordular.AnagramView do
  use Wordular.Web, :view

  def anagram_output(anagrams) do
    Enum.map(anagrams, fn(word) -> "<li>#{word}</li>" end)
  end
end
