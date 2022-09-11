defmodule ChatWeb.MessageLive do
  use ChatWeb, :live_view
  alias Chat.Message
  alias Chat.PubSub

  def mount(_params, _session, socket) do
    if connected?(socket), do: Message.subscribe()

    messages = Message.list_messages() |> Enum.reverse()
    changeset = Message.changeset(%Message{}, %{})
    {:ok, assign(socket, changeset: changeset, messages: messages)}
  end

  def render(assigns) do
    ChatWeb.MessageView.render("messages.html", assigns)
  end

  def handle_event("new_message", %{"message" => params}, socket) do
    case Message.create_message(params) do
      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      :ok ->
        changeset = Message.changeset(%Message{}, %{"name" => params["name"]})
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_info({:message_created, message}, socket) do
    messages = socket.assigns.messages ++ [message]
    {:noreply, assign(socket, messages: messages)}
  end
end
