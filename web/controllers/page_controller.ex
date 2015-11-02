defmodule Wordular.PageController do
  use Wordular.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
