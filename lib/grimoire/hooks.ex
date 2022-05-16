defmodule Grimoire.Hooks do
  alias Grimoire.Context

  def timer_hook(context) do
    now = DateTime.utc_now()

    context
    |> Context.put_hook_data(:start_time, now)
    |> Context.register_post_run_hook(&timer_post_run_hook/1)
  end

  def timer_post_run_hook(context) do
    now = DateTime.utc_now()

    start_time = Context.get_hook_data(context, :start_time)

    context
    |> Context.put_hook_data(:end_time, now)
    |> Context.put_hook_data(:duration_usec, DateTime.diff(now, start_time, :microsecond))
  end

  def get_duration(context) do
    Context.get_hook_data(context, :duration_usec)
  end
end
