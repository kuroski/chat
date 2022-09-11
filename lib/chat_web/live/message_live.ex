defmodule ChatWeb.MessageLive do
  use ChatWeb, :live_view
  alias Chat.Message
  alias Chat.PubSub
  alias Chat.Presence
  on_mount ChatWeb.AuthController

  @presence_topic "liveview_chat_presence"

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Message.subscribe()

      {id, name} =
        if socket.assigns.current_user do
          {socket.assigns.current_user.id, socket.assigns.current_user.name}
        else
          {socket.id, "guest"}
        end

      {:ok, _} = Presence.track(self(), @presence_topic, id, %{name: name})
      Phoenix.PubSub.subscribe(PubSub, @presence_topic)
    end

    messages = Message.list_messages() |> Enum.reverse()

    changeset =
      if socket.assigns.current_user do
        Message.changeset(%Message{}, %{"name" => socket.assigns.current_user.name})
      else
        Message.changeset(%Message{}, %{})
      end

    {:ok,
     assign(
       socket,
       messages: messages,
       changeset: changeset,
       presence: get_presence_names()
     ), temporary_assigns: [messages: []]}
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

  def handle_info(%{event: "presence_diff", payload: _diff}, socket) do
    {:noreply, assign(socket, presence: get_presence_names())}
  end

  defp get_presence_names() do
    Presence.list(@presence_topic)
    |> Enum.map(fn {_k, v} -> List.first(v.metas).name end)
    |> group_names()
  end

  # return list of names and number of guests
  defp group_names(names) do
    loggedin_names = Enum.filter(names, fn name -> name != "guest" end)

    guest_names =
      Enum.count(names, fn name -> name == "guest" end)
      |> guest_names()

    if guest_names do
      [guest_names | loggedin_names]
    else
      loggedin_names
    end
  end

  defp guest_names(0), do: nil
  defp guest_names(1), do: "1 guest"
  defp guest_names(n), do: "#{n} guests"
end
