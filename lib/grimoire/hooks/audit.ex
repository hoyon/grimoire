defmodule Grimoire.Hooks.Audit do
  import Ecto.Query
  alias Grimoire.{Context, Repo}
  alias Grimoire.Hooks.Audit.Execution

  def hook(context) do
    id = insert_execution(context)

    context
    |> Context.put_hook_data(:audit_id, id)
    |> Context.register_post_run_hook(&post_run_hook/1)
  end

  def post_run_hook(context) do
    id = Context.get_hook_data(context, :audit_id)

    update_execution(id, context)

    context
  end

  def history(spell_book, spell) do
    spell_id_string = Atom.to_string(spell.id)
    spell_book_string = Atom.to_string(spell_book)

    Repo.all(
      from(e in Execution,
        where: e.spell_id == ^spell_id_string and e.spell_book == ^spell_book_string,
        order_by: {:desc, :started_at}
      )
    )
  end

  def prune_history do
    one_day = 60 * 60 * 24
    threshold = DateTime.utc_now() |> DateTime.add(-1 * one_day, :second)
    Repo.delete_all(from e in Execution, where: e.finished_at < ^threshold)
  end

  defp insert_execution(context) do
    {:ok, %{id: id}} =
      Repo.insert(%Execution{
        spell_book: Atom.to_string(context.spell_book),
        spell_id: Atom.to_string(context.spell.id),
        started_at: DateTime.utc_now(),
        status: "started",
        metadata: context.metadata
      })

    id
  end

  defp update_execution(id, context) do
    Repo.update_all(from(e in "grimoire_executions", where: e.id == ^id),
      set: [
        status: status(context),
        finished_at: DateTime.utc_now(),
        error_message: context.error_message
      ]
    )
  end

  defp status(%{error: true}), do: "failed"
  defp status(%{error: false}), do: "finished"
end
