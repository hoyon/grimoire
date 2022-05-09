defmodule GrimoireWeb.SpellController do
  use GrimoireWeb, :controller
  alias GrimoireWeb.Spells

  @spell_book GrimoireWeb.SpellBook

  def index(conn, _params) do
    render(conn, "index.html", spells: Spells.all(@spell_book))
  end

  def show(conn, %{"spell" => spell_id}) do
    case Spells.get(@spell_book, spell_id) do
      nil ->
        render(conn, "not_found.html")

      spell ->
        render(conn, "show.html", spell: spell)
    end
  end

  def perform(conn, %{"spell" => spell_id, "params" => params}) do
    case Spells.cast(@spell_book, spell_id, params) do
      {:error, %{error_message: message, duration_ms: duration}} ->
        conn
        |> put_flash(:error, "Error! Message: #{message}. Failed after #{duration}ms")
        |> redirect(to: Routes.spell_path(conn, :show, spell_id))

      {:ok, %{result: res, duration_ms: duration}} ->
        conn
        |> put_flash(:info, "Success! Result: #{res}. Took #{duration}ms")
        |> redirect(to: Routes.spell_path(conn, :show, spell_id))
    end
  end
end
