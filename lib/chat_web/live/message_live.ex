defmodule ChatWeb.MessageLive do
  use ChatWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ChatWeb.MessageView.render("message.html", assigns)
  end
end
