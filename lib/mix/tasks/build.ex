defmodule Mix.Tasks.Build do
  def run(_args) do
    Mix.Task.run("app.start")
    Reefpoints.build()
  end
end