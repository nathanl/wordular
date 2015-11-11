defmodule Wordular.AnagramController do
  use Wordular.Web, :controller

  def index(conn, _params) do
    # specifying template name as :index instead of "index.html" tells it to
    # choose a template based on the Accept headers - .html, .json, etc.
    render conn, :index
  end

  def show(conn, %{"phrase" => phrase}) do
    anagrams = Anagrams.for(phrase)
    render conn, "show.html", phrase: phrase, anagrams: anagrams
  end
 
end
