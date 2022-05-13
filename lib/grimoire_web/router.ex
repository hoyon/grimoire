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

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GrimoireWeb do
    pipe_through :browser

    get "/", PageController, :index

    get "/spell", SpellController, :index
    get "/spell/:spell", SpellController, :show
    post "/spell/:spell", SpellController, :perform

    live "/spells_live", SpellsLive
    live "/spells_live/:id", CastLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", GrimoireWeb do
  #   pipe_through :api
  # end
end
