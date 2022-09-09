defmodule ChatWeb.MessageLiveTest do
  use ChatWeb.ConnCase
  import Phoenix.LiveViewTest

  test "disconnected and connected mount", %{conn: conn} do
    conn = get(conn, "/live")
    assert html_response(conn, 200) =~ "Chat Example"

    {:ok, _view, _html} = live(conn)
  end
end
