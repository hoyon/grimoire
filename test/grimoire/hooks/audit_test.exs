defmodule Grimoire.Hooks.AuditTest do
  use Grimoire.DataCase, async: true
  import Ecto.Query
  alias Grimoire.{Context, Repo}
  alias Grimoire.Hooks.Audit

  test "hook/1" do
    context = Audit.hook(%Context{spell_book: MySpellBook, spell: %{id: :spell_name}})

    exe = get_execution()

    assert exe.spell_id == "spell_name"
    assert exe.spell_book == "Elixir.MySpellBook"
    assert exe.status == "started"
    assert is_nil(exe.finished_at)

    Context.run_post_run_hooks(context)

    exe = get_execution()

    assert exe.spell_id == "spell_name"
    assert exe.spell_book == "Elixir.MySpellBook"
    assert exe.status == "finished"
    refute is_nil(exe.finished_at)
  end

  test "with error sets status to error" do
    context = Audit.hook(%Context{spell_book: MySpellBook, spell: %{id: :spell_name}})

    context = %{context | error: true, error_message: "Something went wrong!!"}

    Context.run_post_run_hooks(context)

    exe = get_execution()
    assert exe.status == "failed"
    assert exe.error_message == "Something went wrong!!"
  end

  test "history" do
    Audit.hook(%Context{spell_book: MySpellBook, spell: %{id: :my_spell}})
    Audit.hook(%Context{spell_book: MySpellBook, spell: %{id: :my_spell}})
    Audit.hook(%Context{spell_book: MySpellBook, spell: %{id: :my_spell}})

    Audit.hook(%Context{spell_book: MySpellBook, spell: %{id: :other_spell}})

    history = Audit.history(MySpellBook, %{id: :my_spell})

    assert length(history) == 3
  end

  test "prune history" do
    days_ago = DateTime.utc_now() |> DateTime.add(60 * 60 * 24 * -5, :second)

    old = %{spell_book: "Elixir.MySpellBook", spell_id: "my_spell", started_at: days_ago, finished_at: days_ago, status: "finished", metadata: %{}}
    recent = %{spell_book: "Elixir.MySpellBook", spell_id: "my_spell", started_at: days_ago, finished_at: DateTime.utc_now(), status: "finished", metadata: %{}}

    Repo.insert_all("grimoire_executions", List.duplicate(old, 10))
    Repo.insert_all("grimoire_executions", List.duplicate(recent, 5))

    assert length(Audit.history(MySpellBook, %{id: :my_spell})) == 15

    Audit.prune_history()

    assert length(Audit.history(MySpellBook, %{id: :my_spell})) == 5
  end

  defp get_execution do
    Repo.one(
      from(e in "grimoire_executions",
        select: [:id, :spell_id, :spell_book, :status, :finished_at, :error_message]
      )
    )
  end
end
