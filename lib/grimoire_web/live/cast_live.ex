defmodule GrimoireWeb.CastLive do
  use GrimoireWeb, :live_view
  alias GrimoireWeb.SpellsLive
  alias Grimoire.Hooks.Audit

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
      |> assign(:history, Audit.history(@spell_book, spell))

    {:ok, socket}
  end

  def handle_event("cast", %{"params" => params}, socket) do
    task =
      Task.Supervisor.async_nolink(Grimoire.TaskSupervisor, fn ->
        Grimoire.cast(@spell_book, params[@spell_id_field], Map.delete(params, @spell_id_field))
      end)

    socket = assign(socket, :task, task)

    {:noreply, socket}
  end

  def handle_event("cancel", _, socket) do
    Task.Supervisor.terminate_child(Grimoire.TaskSupervisor, socket.assigns.task.pid)

    {:noreply, socket}
  end

  def handle_info({ref, context}, socket) do
    Process.demonitor(ref, [:flush])

    socket =
      socket
      |> assign(:task, nil)
      |> assign(:context, context)
      |> assign(:history, Audit.history(@spell_book, socket.assigns.spell))

    {:noreply, socket}
  end

  def handle_info({:DOWN, _, _, _, _}, socket) do
    socket =
      socket
      |> assign(:task, nil)
      |> assign(:context, nil)

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

  defp format_datetime(nil), do: nil
  defp format_datetime(datetime) do
    [
      datetime |> DateTime.to_date() |> Date.to_string(),
      " ",
      datetime |> DateTime.to_time() |> Time.truncate(:second) |> Time.to_string()
    ]
  end
end
