defmodule ChatWeb.MessageLive do
  use ChatWeb, :live_view
  alias Chat.Message
  alias Chat.PubSub
  on_mount ChatWeb.AuthController

  def mount(_params, _session, socket) do
    if connected?(socket), do: Message.subscribe()

    messages = Message.list_messages() |> Enum.reverse()

    changeset =
      if socket.assigns.current_user do
        Message.changeset(%Message{}, %{"name" => socket.assigns.current_user.name})
      else
        Message.changeset(%Message{}, %{})
      end

    {:ok, assign(socket, messages: messages, changeset: changeset),
     temporary_assigns: [messages: []]}
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
    {:noreply, assign(socket, messages: [message])}
  end
end
