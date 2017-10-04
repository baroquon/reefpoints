---
layout: post
title: "Testing function delegation in Elixir without stubbing"
author: 'Brian Cardarella'
twitter: 'bcardarella'
github: bcardarella
published: true
tags: engineering, elixir, testing
---

In other lanugages mocking/stubbing are part of your regular toolbelt, in Elixir Jose has
come out against them 

<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
<blockquote class="twitter-tweet" data-lang="en">
  <p lang="en" dir="ltr">
    I will fight against mocks, stubs and YAML in Elixir with all my... friendliness and energy to promote proper education on those topics.
  </p>
  &mdash; José Valim (@josevalim) 
  <a href="https://twitter.com/josevalim/status/641617411242913792">September 9, 2015</a>
</blockquote>

Instead he suggests

<blockquote class="twitter-tweet" data-lang="en">
  <p lang="en" dir="ltr">
    <a href="https://twitter.com/bcardarella">@bcardarella</a> 
    for tests, create a simple module (or an agent if you need flexibility) that will be used by your app during your tests
  </p>
  &mdash; José Valim (@josevalim) 
  <a href="https://twitter.com/josevalim/status/641619543543152640">September 9, 2015</a>
</blockquote>

I've been trying to practice this until the other day when I was
building a library that was adapter based. I wanted to unit test the
parent module that would delegate to the adapter. The adapters can
change and I don't want the unit test of the parent module to be tied to
any particular child. As a matter of example, we could have something
like this:

```elixir
defmodule Parent do
  defmacro __using__([adapter: adapter]) do
    quote do
      def __adapter__, do: unquote(adapter)
      def make_it_so(command) do
        __adapter__.make_it_so(command)
      end
    end
  end
end
```

In other languages I would stub out `Parent.make_it_so/1` and assert that
this function was being called. For example, if you were using the
[`mock`][mock] Elixir library you would do:

```elixir
defmodule CustomParent do
  use Parent, adapter: FooBar
end

with_mock CustomParent, [make_it_so: fn(command) -> command end] do
  CustomParent.make_it_so(:ok)
end
```

But as Jose has pointed out we don't want to do this.
So how do we test that the adapter's `make_it_so/1` function is being
properly delegated to without stubbing? Well we can rely on Elixir's
[`send/3`][send] and [`assert_receive`][assert_receive].

Keep in mind that `send` will allow you to put messages into a process's
mailbox and `assert_receive` will allow you to test against that.

Here is how you might test the delegation:

```elixir
defmodule ParentTest do
  use ExUnit.Case

  defmodule CustomAdapter do
    def make_it_so(_command) do
      send self(), :ok
    end
  end

  defmodule CustomParent do
    use Parent, adapter: CustomAdapter
  end

  test "delegates to the adapter" do
    CustomParent.make_it_so(%{foo: "bar"})

    assert_receive :ok
  end
end
```

And that's it. You can handle more complex situations by adding your own
logic inside the `CustomAdapter`s function, to send or not send
depending upon the value passed in but that should depend upon your
use-case.

So what happens when you are testing with a module that might spawn its
own process? In those cases I might have an `opts` argument that I can
work with. Let's assume that for whatever reason `Parent.make_it_so`
is working in a process on its own:

```elixir
defmodule ParentTest do
  use ExUnit.Case

  defmodule CustomAdapter do
    def make_it_so(_command, opts) do
      send opts[:pid], :ok
    end
  end

  defmodule CustomParent do
    use Parent, adapter: CustomAdapter
  end

  test "delegates to the adapter" do
    opts = [pid: self()]
    CustomParent.make_it_so(%{foo: "bar"}, opts)

    assert_receive :ok
  end
end
```

This works because each test in `ExUnit` runs in its own process. You
could even do this in a `setup` block if you needed to capture the PID
for many tests. However, you cannot do this in `setup_all` as that runs
in a different process than the individual tests.

Testing in Elixir has been fun as it has forced me to think about things
differently than I've been used to over the past few years. If this
topic is of interest to you check out my talk from [ElixirDaze][elixirdaze] on Building and Testing
Phoenix APIs

<iframe width="560" height="315" src="https://www.youtube.com/embed/zoP-XFuWstw" frameborder="0" allowfullscreen></iframe>

[ecto]: https://github.com/elixir-lang/ecto/blob/master/lib/ecto/repo.ex#L83-L100
[send]: http://elixir-lang.org/docs/stable/elixir/Process.html#send/3
[assert_receive]: http://elixir-lang.org/docs/stable/ex_unit/ExUnit.Assertions.html#assert_receive/3
[elixirdaze]: http://elixirdaze.com
[mock]: https://github.com/jjh42/mock
