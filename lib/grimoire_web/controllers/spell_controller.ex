defmodule GrimoireWeb.SpellController do
  use GrimoireWeb, :controller
  alias GrimoireWeb.Spells

  def index(conn, _params) do
    render(conn, "index.html", spells: Spells.all())
  end

  def show(conn, %{"spell" => spell_id}) do
    case Spells.get(spell_id) do
      nil ->
        render(conn, "not_found.html")

      spell ->
        render(conn, "show.html", spell: spell)
    end
  end

  def perform(conn, %{"spell" => spell_id, "params" => params}) do
    case Spells.perform(spell_id, params) do
      %{status: :error, error_message: message, duration_ms: duration} ->
        conn
        |> put_flash(:error, "Error! Message: #{message}. Failed after #{duration}ms")
        |> redirect(to: Routes.spell_path(conn, :show, spell_id))

      %{status: :ok, result: res, duration_ms: duration} ->
        conn
        |> put_flash(:info, "Success! Result: #{res}. Took #{duration}ms")
        |> redirect(to: Routes.spell_path(conn, :show, spell_id))
    end
  end
end
