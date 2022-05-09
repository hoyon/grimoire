defmodule GrimoireWeb.SpellsLive do
  use GrimoireWeb, :live_view
  alias GrimoireWeb.Spells
  alias GrimoireWeb.CastLive

  @spell_book GrimoireWeb.SpellBook

  def mount(_params, _assigns, socket) do
    socket = assign(socket, :spells, Spells.all(@spell_book))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <%= for spell <- @spells do %>
      <div>
        <%= live_redirect spell.name, to: Routes.live_path(@socket, CastLive, spell.id) %>
      </div>
    <% end %>
    """
  end
end
