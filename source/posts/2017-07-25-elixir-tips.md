---
layout: post
title: "5 Elixir tricks you should know"
summary: "Elixir tricks"
author: "Daniel Xu"
twitter: "Daniel_Xu_For"
github: "Daniel-Xu"
published: true
tags: Elixir
---

## alias `__MODULE__`
This one looks mysterious at first, but once we break it down, it's very straightforward.

`alias` allows you to define aliases for the module name, for example:

`alias Foo.Bar` will set up an alias for module `Foo.Bar`, and you can reference that module with just `Bar`.

`__MODULE__` is a compilation environment macros which is the current module name as an atom.

Now you know `alias __MODULE__` just defines an alias for our Elixir module. This is very useful when used with `defstruct` which we will talk about next.

In the following example, we pass `API.User` struct around to run some checks on our data. Instead of writing the full module name, we set up an alias `User` for it and pass that around. It's pretty concise and easy to read.

```elixir
defmodule API.User do
  alias __MODULE__

  defstruct name: nil, age: 0

  def old?(%User{name: name, age: age} = user) do
    ...
  end
end
```

In case of module name changing, you can also do this:

```
alias __MODULE__, as: SomeOtherName
```

## defstruct with @enforce_keys

whenever you want to model your data with `maps`, you should also consider `struct` because `struct` is a `tagged map` which offers compile time checks on the key and allows us to do
run-time checks on the struct's type, for example:

you can't create a struct with field that is not defined. In the following example you can also see how we apply the first trick we just learned.

```elixir
defmodule Fun.Game do
  alias __MODULE__
  defstruct(
    time: nil,
    status: :init
  )

  def new() do
    %Game{step: 1}
  end
end

iex> IO.inspect Fun.Game.new()
iex> ** (KeyError) key :step not found in: %{__struct__: Fun.Game, status: :init, time: nil}
```

However, sometime you wanna ensure that some fields are present whenever you create a new struct. Fortunately, Elixir provides  `@enforce_keys` module attribute for that:

```elixir
defmodule Fun.Game do
  @enforce_keys [:status]

  alias __MODULE__
  defstruct(
    time: nil,
    status: :init
  )

  def new() do
    %Game{}
  end
end

iex> Fun.Game.new()
iex> ** (ArgumentError) the following keys must also be given when building struct Fun.Game: [:status]
```

Based on the result, you can see that in this case we can't rely on the default value of `status`, we need to specify its value when we create a new Game:

```elixir
def new(status) do
  %Game{status: status}
end

iex> Fun.Game.new(:won)
iex> %Fun.Game{status: :won, time: nil}
```

## `v()` function in `iex`

Whenever I wrote a `GenServer` module, I usually want to start the server and check the result in `iex`.
One thing that really bothers me is that I almost always forget to pattern match the process pid, like this:

```elixir
iex(1)> Metex.Worker.start_link()
{:ok, #PID<0.472.0>}
```

then, I need to type that command again with pattern matching:

```
{:ok, pid} = Metex.Worker.start_link()
```

Being tired of doing this over and over again, I found that you can use `v()` to return the result from last command:

```elixir
iex(1)> Metex.Worker.start_link()
{:ok, #PID<0.472.0>}
iex(2)> {:ok, pid} = v()
{:ok, #PID<0.472.0>}
iex(3)>  pid
#PID<0.472.0>
```

This trick saves me couple of seconds every time I use it, I hope that you will find it helpful too.

## cancel bad command in `iex`

Have you ever had this kinda moment when you use `iex`:

```elixir
iex(1)> a = 1 + 1'
...(2)>
...(2)>
...(2)>
BREAK: (a)bort (c)ontinue (p)roc info (i)nfo (l)oaded
       (v)ersion (k)ill (D)b-tables (d)istribution
```

Normally, I will `ctrl + c` twice to exit `iex` and create a new one. However, sometimes you've already typed in a bunch of commands in it, and you definitely want to keep the session. Here is what you can do: `#iex:break`

```
iex(2)> a = 1 + 1
iex(2)> b = 1 + 1'
...(2)>
...(2)> #iex:break
** (TokenMissingError) iex:1: incomplete expression

iex(2)> a
2
```

From the code block above, you can see that we still have the session after canceling a bad command.

## bind value to an optional variable

I'm sure most of people knew that you can bind a value to an optional variable like this:

```elixir
_dont_care = 1
```

The reason why I bring this up is because we can actually apply this trick to our functions to make them more readable:

```elixir
defp accept_move(game, _guess, _already_used = true) do
  Map.put(game, :state, :already_used)
end
defp accept_move(game, guess, _not_used) do
  Map.put(game, :used, MapSet.put(game.used, guess))
  |> score_guess(Enum.member?(game.letters, guess))
end
```

Thanks for reading this post and always share your Elixir tricks to the community.
