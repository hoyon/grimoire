defmodule GrimoireWeb.SpellController do
  use GrimoireWeb, :controller
  alias GrimoireWeb.Spells

  def index(conn, _params) do
    render(conn, "index.html", spells: Spells.all())
  end

  def show(conn, %{"spell" => spell_name}) do
    case Spells.get(spell_name) do
      nil ->
        render(conn, "not_found.html")

      spell ->
        render(conn, "show.html", spell: spell)
    end
  end

  def perform(conn, %{"spell" => spell_name, "params" => params}) do
    case Spells.perform(spell_name, params) do
      :error ->
        conn
        |> put_flash(:error, "Failed to cast spell")
        |> redirect(to: Routes.spell_path(conn, :show, spell_name))

      _ ->
        conn
        |> put_flash(:info, "cast!")
        |> redirect(to: Routes.spell_path(conn, :show, spell_name))
    end
  end
end
