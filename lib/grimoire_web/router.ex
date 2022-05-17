defmodule GrimoireWeb.Router do
  use GrimoireWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {GrimoireWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", GrimoireWeb do
    pipe_through :browser

    live "/", SpellsLive
    live "/:id", CastLive
  end
end
