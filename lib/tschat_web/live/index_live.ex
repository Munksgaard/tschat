defmodule TschatWeb.IndexLive do
  use TschatWeb, :live_view

  alias TschatWeb.Endpoint

  @impl true
  def mount(_params, session, socket) do
    user = session["user"]

    socket =
      socket
      |> stream(:presences, [])
      |> stream(:messages, [])
      |> assign(form: to_form(%{}))
      |> assign(:user, user)

    socket =
      if connected?(socket) do
        TschatWeb.Presence.track_user(user.id, %{id: user.id, display_name: user.display_name})
        TschatWeb.Presence.subscribe()
        Endpoint.subscribe("room:lobby")
        stream(socket, :presences, TschatWeb.Presence.list_online_users())
      else
        socket
      end

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="container mx-auto my-8 p-6 bg-base-100 rounded-lg shadow-xl max-w-screen-lg">
        <div class="flex h-[70vh] border border-base-300 rounded-lg overflow-hidden">
          <div class="w-64 bg-base-200 p-4 border-r border-base-300 overflow-y-auto flex-shrink-0 hidden md:block">
            <h2 class="text-lg font-bold mb-4 text-base-content">Online Users</h2>
            <ul id="online_users" phx-update="stream" class="space-y-2 text-sm text-base-content/80">
              <li
                :for={{dom_id, %{user: user}} <- @streams.presences}
                id={dom_id}
                class="p-1 rounded hover:bg-base-300"
              >
                {user.display_name}
              </li>
            </ul>
          </div>

          <div class="flex-1 flex flex-col bg-base-100">
            <div class="p-4 border-b border-base-300">
              <h1 class="text-xl font-bold text-base-content">Lobby Chat</h1>
            </div>

            <div id="messages" phx-update="stream" class="flex-grow p-4 overflow-y-auto space-y-4">
              <div
                :for={
                  {dom_id, %{user_display_name: user_display_name, message: message}} <-
                    @streams.messages
                }
                id={dom_id}
                class={[
                  "chat",
                  if(user_display_name == @user.display_name,
                    do: "chat-end",
                    else: "chat-start"
                  )
                ]}
              >
                <div class="chat-header">
                  {user_display_name}
                </div>
                <div class="chat-bubble">
                  {message}
                </div>
              </div>
            </div>

            <div class="p-4 bg-base-200 border-t border-base-300">
              <.form
                for={@form}
                id="message-form"
                phx-change="validate"
                phx-submit="save"
                class="flex items-center space-x-4"
              >
                <.input
                  field={@form[:message]}
                  type="text"
                  class="flex-grow input input-bordered w-full"
                  placeholder="Type your message..."
                />

                <.button phx-disable-with="Sending..." variant="primary" class="btn btn-primary">
                  Send
                </.button>
              </.form>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("validate", message_params, socket) do
    {:noreply, assign(socket, form: to_form(message_params))}
  end

  def handle_event("save", message_params, socket) do
    Endpoint.broadcast(
      "room:lobby",
      "new_message",
      Map.put(message_params, "user_display_name", socket.assigns.user.display_name)
    )

    {:noreply, socket}
  end

  @impl true
  def handle_info({TschatWeb.Presence, {:join, presence}}, socket) do
    {:noreply, stream_insert(socket, :presences, presence)}
  end

  def handle_info({TschatWeb.Presence, {:leave, presence}}, socket) do
    if presence.metas == [] do
      {:noreply, stream_delete(socket, :presences, presence)}
    else
      {:noreply, stream_insert(socket, :presences, presence)}
    end
  end

  def handle_info(%{event: "new_message", payload: payload}, socket) do
    {:noreply,
     socket
     |> stream_insert(:messages, %{
       id: System.unique_integer(),
       message: payload["message"],
       user_display_name: payload["user_display_name"]
     })}
  end
end
