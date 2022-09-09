defmodule ChatWeb.MessageLive do
  use ChatWeb, :live_view
  alias Chat.Message

  def mount(_params, _session, socket) do
    messages = Message.list_messages() |> Enum.reverse()
    changeset = Message.changeset(%Message{}, %{})
    {:ok, assign(socket, changeset: changeset, messages: messages)}
  end

  def render(assigns) do
    ChatWeb.MessageView.render("messages.html", assigns)
  end
end
