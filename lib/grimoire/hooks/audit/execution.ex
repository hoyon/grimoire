defmodule Grimoire.Hooks.Audit.Execution do
  use Ecto.Schema

  schema "grimoire_executions" do
    field :spell_book, :string
    field :spell_id, :string
    field :status, :string
    field :error_message, :string
    field :metadata, :map
    field :started_at, :utc_datetime_usec
    field :finished_at, :utc_datetime_usec
  end
end
