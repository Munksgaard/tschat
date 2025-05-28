defmodule TschatWeb.Router do
  use TschatWeb, :router

  defp plug_auth(conn, _opts) do
    case conn.assigns.tailscale_user do
      %{"CapMap" => cap_map, "UserProfile" => user_profile} ->
        user = %{
          ip: conn.assigns.tailscale_ip,
          cap: cap_map,
          display_name: user_profile["DisplayName"],
          id: user_profile["ID"],
          login_name: user_profile["LoginName"],
          profile_pic_url: user_profile["ProfilePicUrl"],
          roles: user_profile["Roles"]
        }

        Plug.Conn.put_session(conn, :user, user)

      _ ->
        conn |> Plug.Conn.put_status(403) |> Plug.Conn.halt()
    end
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TschatWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TschatWeb do
    pipe_through [:browser, TailscaleTransport.Plug, :plug_auth]

    live "/", IndexLive, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", TschatWeb do
  #   pipe_through :api
  # end
end
