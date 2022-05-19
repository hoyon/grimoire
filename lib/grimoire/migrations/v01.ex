defmodule Grimoire.Migrations.V01 do
  use Ecto.Migration

  def up do
    create table(:grimoire_executions) do
      add :spell_book, :string, null: false
      add :spell_id, :string, null: false
      add :status, :string, null: false
      add :error_message, :text, null: true
      add :metadata, :map, null: false

      add :started_at, :timestamptz, null: false
      add :finished_at, :timestamptz, null: true
    end

    create index(:grimoire_executions, [:spell_book, :spell_id])
  end

  def down do
    drop table(:grimoire_executions)
  end
end
