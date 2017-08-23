defmodule Mix.Tasks.Build do
  def run(_args) do
    Reefpoints.build()
  end
end