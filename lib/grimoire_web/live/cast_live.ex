defmodule GrimoireWeb.CastLive do
  use GrimoireWeb, :live_view
  alias GrimoireWeb.SpellsLive

  @spell_book GrimoireWeb.SpellBook
  @spell_id_field "__grimoire_spell_id"

  def mount(%{"id" => spell_id}, _assigns, socket) do
    spell = Grimoire.get(@spell_book, spell_id)

    socket =
      socket
      |> assign(:spell, spell)
      |> assign(:task, nil)
      |> assign(:context, nil)
      |> assign(:spell_id_field, @spell_id_field)

    {:ok, socket}
  end

  def handle_event("cast", %{"params" => params}, socket) do
    task =
      Task.Supervisor.async_nolink(Grimoire.TaskSupervisor, fn ->
        Grimoire.cast(@spell_book, params[@spell_id_field], params)
      end)

    socket = assign(socket, :task, task)

    {:noreply, socket}
  end

  def handle_info({ref, context}, socket) do
    Process.demonitor(ref, [:flush])

    socket =
      socket
      |> assign(:task, nil)
      |> assign(:context, context)

    {:noreply, socket}
  end

  defp format_result(%{result: nil}), do: "Ok"
  defp format_result(%{result: res}), do: inspect(res)

  defp required?(%{opts: opts}) do
    Keyword.get(opts, :required, true)
  end

  defp required?(_), do: true

  defp description(%{opts: opts}) do
    Keyword.get(opts, :description, nil)
  end

  defp description(_), do: nil

  defp select_options(%{opts: opts}) do
    Keyword.fetch!(opts, :options)
  end

  defp duration(context) do
    format_duration(Grimoire.Hooks.get_duration(context))
  end

  defp format_duration(nil), do: nil

  defp format_duration(duration) do
    if duration > 1000 do
      [duration |> div(1000) |> Integer.to_string(), "ms"]
    else
      [Integer.to_string(duration), "µs"]
    end
  end
end
