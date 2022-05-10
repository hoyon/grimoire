defmodule GrimoireWeb.CastLive do
  use GrimoireWeb, :live_view
  alias GrimoireWeb.Spells
  alias GrimoireWeb.SpellsLive

  @spell_book GrimoireWeb.SpellBook
  @spell_id_field "__grimoire_spell_id"

  def mount(%{"id" => spell_id}, _assigns, socket) do
    spell = Spells.get(@spell_book, spell_id)

    socket =
      socket
      |> assign(:spell, spell)
      |> assign(:task, nil)
      |> assign(:result, nil)
      |> assign(:error, nil)
      |> assign(:spell_id_field, @spell_id_field)

    {:ok, socket}
  end

  def handle_event("cast", %{"params" => params}, socket) do
    IO.inspect(params)

    task =
      Task.Supervisor.async_nolink(Grimoire.TaskSupervisor, fn ->
        Spells.cast(@spell_book, params[@spell_id_field], params)
      end)

    socket = assign(socket, :task, task)

    {:noreply, socket}
  end

  def handle_info({ref, {:ok, result}}, socket) do
    Process.demonitor(ref, [:flush])

    socket =
      socket
      |> assign(:task, nil)
      |> assign(:result, result)

    {:noreply, socket}
  end

  def handle_info({ref, {:error, result}}, socket) do
    Process.demonitor(ref, [:flush])

    socket =
      socket
      |> assign(:task, nil)
      |> assign(:error, result)

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
      <%= hidden_input :params, @spell_id_field, value: @spell.id %>

      <%= for param <- @spell.params do %>
        <%= label :params, param.name, param.name %>

        <%= case param.type do %>
          <% :string -> %>
            <%= text_input :params, param.name, required: required?(param) %>
          <% :integer -> %>
            <%= number_input :params, param.name, required: required?(param) %>
        <% end %>
      <% end %>

      <%= submit "Do it!", disabled: not is_nil(@task) %>
    </.form>

    <%= if not is_nil(@result) do %>
    <div>
      <div>
        Took: <%= @result[:duration_ms] %>ms
      </div>
      <div>
        Result: <%= @result[:result] %>
      </div>
    </div>
    <% end %>

    <%= if not is_nil(@error) do %>
    <div>
      <div>
        Took: <%= @error[:duration_ms] %>ms
      </div>
      <div>
        Result: <%= @error[:error_message] %>
      </div>
    </div>
    <% end %>
    """
  end

  defp required?(%{opts: opts}) do
    Keyword.get(opts, :optional, false) == false
  end

  defp required?(_), do: true
end
