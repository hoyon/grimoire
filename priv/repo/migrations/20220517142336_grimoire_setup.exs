defmodule Grimoire.Repo.Migrations.GrimoireSetup do
  use Ecto.Migration

  def up do
    Grimoire.Migrations.V01.up()
  end

  def down do
    Grimoire.Migrations.V01.down()
  end
end
