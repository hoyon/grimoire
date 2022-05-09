defmodule GrimoireWeb.CastLive do
  use GrimoireWeb, :live_view
  alias GrimoireWeb.Spells
  alias GrimoireWeb.SpellsLive

  @spell_book GrimoireWeb.SpellBook

  def mount(%{"id" => spell_id}, _assigns, socket) do
    spell = Spells.get(@spell_book, spell_id)

    socket = assign(socket, :spell, spell)

    {:ok, socket}
  end

  def handle_event("cast", %{"params" => params}, socket) do
    IO.inspect(params)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <%= live_redirect "Index", to: Routes.live_path(@socket, SpellsLive) %>
    </div>

<h1><%= @spell.name %></h1>

    <%= if @spell.description do %>
      <p>
        <%= @spell.description %>
      </p>
    <% end %>

    <.form for={:spell} phx-submit="cast">

      <%= for param <- @spell.params do %>
        <%= label :params, param.name, param.name %>

        <%= case param.type do %>
          <% :string -> %>
            <%= text_input :params, param.name, required: required?(param) %>
          <% :integer -> %>
            <%= number_input :params, param.name, required: required?(param) %>
        <% end %>
      <% end %>

      <%= submit "Do it!" %>
    </.form>
    """
  end

  defp required?(%{opts: opts}) do
    Keyword.get(opts, :optional, false) == false
  end

  defp required?(_), do: true
end
