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

  defp get_execution do
    Repo.one(
      from(e in "grimoire_executions",
        select: [:id, :spell_id, :spell_book, :status, :finished_at, :error_message]
      )
    )
  end
end
