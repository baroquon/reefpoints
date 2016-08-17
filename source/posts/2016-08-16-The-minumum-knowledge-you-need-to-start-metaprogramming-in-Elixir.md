---
layout: post
title: "The minimum knowledge you need to start Metaprogramming in Elixir"
summary: "Metaprogramming Elixir"
author: "Daniel Xu"
twitter: "Daniel_Xu_For"
github: "Daniel-Xu"
published: true
tags: Elixir
---

Basically, metaprogramming is `writing code that writes code`. In Elixir, we use `Macro` to transform our internal program structure (AST) in compile time to something else. For example, the `if` macro is transformed to `case` during compilation, we call this `macro expansion`.

```elixir
if true do
  IO.puts "yea"
end

# becomes

case(true) do
  x when x in [false, nil] ->
    nil
  _ ->
    IO.puts("yea")
end
```

## The Abstract Syntax Tree (AST) and AST literal

The internal representation of Elixir code which is called [abstract syntax tree](https://en.wikipedia.org/wiki/Abstract_syntax_tree) is the protagonist in program transformation. Elixir also calls AST `quoted expression`.

The quoted expression is composed of three-element tuples:

```elixir
# simple one: AST for 1 + 2
{:+, [context: Elixir, import: Kernel], [1, 2]}

# nested one:
# AST for
# def hello do
#	IO.puts "hello"
# end

{:def, [context: Elixir, import: Kernel],
 [{:hello, [context: Elixir],
   [[do: {{:., [], [{:__aliases__, [alias: false], [:IO]}, :puts]}, [],
      ["hello"]}]]}]}

```
Essentially, All tuples in the AST follow the same pattern:

`{function_call, meta_data_for_context, argument_list}`

During compilation, all of our source code will be **transformed into AST** before producing final bytecode. However, there are **five** Elixir literals that will remain the same format as their high-level source.

![](http://d.pr/i/1ddgz+)

The following example shows the differences between normal type and Elixir literal:

```elixir
# AST for {1, 2, 3}
{:{}, [], [1, 2, 3]}

# AST for {1, 2} (AST literal)
{1, 2}
```

## Macro

**Macros receive AST as arguments and provide AST as return values**. The returned AST is injected back into the global program’s compile tree, in this way, macros enable syntactic extensions and code generation.

* Syntactic extensions: e.g. we can implement `while` which is not available in Elixir or create DSL
* Code generation: e.g. generate function from external data

### Return AST

There are three ways to create quoted expressions in Elixir:

1. Manually construct it
2. `Macro.escape`
3. `quote`/`unquote` to compose AST

```elixir
defmodule MyMacro do
  @opts: %{time: :am}

  # case 1
  defmacro one_plus_two do
 	{:+, [], [1, 2]}
  end

  # case 2
  defmacro say_hi do
    quote do
      IO.puts "hello world"
    end
  end

  # case 3
  defmacro ops do
  	Macro.escape(@opts)
  end
end

defmodule MyModule do
  import Mymacro

  def case1 do
  	IO.puts one_plus_two()
  end

  def case2 do
  	say_hi()
  end

  def case3 do
  	IO.inspect ops()
  end
end

#=> c "example.exs"
#=> MyModule.case1()
#=> "3"
#=> MyModule.case2()
#=> "hello world"
#=> MyModule.case3()
#=> %{time: :am}
```

In this example, we define three macros using `defmacro`, both of them return quoted expressions, then we import `MyMacro` module into `MyModule`. During compilation, these macros will be expanded and the returned AST will be injected into `MyModule's` compile tree.

When it comes to a complex situation, it will be very hard to construct AST manually, we should use `quote` and `Macro.escape`. The main differences between these two are:

* `quote` returns AST of passed in code block.

* `Macro.escape` returns AST of passed in value.

Here are some examples:

```elixir
data = {1, 2, 3}

quote do: {1, 2, 3}
#=> {:{}, [], [1, 2, 3]} (AST of {1, 2, 3})

quote do: data
#=> {:data, [], Elixir} (data is not inject into returned AST)

quote do: IO.inspect(1)
#=> {{:., [], [{:__aliases__, [alias: false], [:IO]}, :inspect]}, [], [1]}
quote do: IO.inspect(data)
#=>{{:., [], [{:__aliases__, [alias: false], [:IO]}, :inspect]}, [],
 [{:data, [], Elixir}]}

Macro.escape(data)
#=> {:{}, [], [1, 2, 3]}

IO.inspect(1)
|> Macro.escape()
#=> :error
```
Notice that `data` variable is not injected into AST returned by `quote` block, in order to do that, we need to use `unquote` which we will discuss later.


### Receive AST

Let's take an example to see how macros receive AST:

```elixir
defmodule M do
  defmacro macro_args(a, b) do
    IO.inspect a
    IO.inspect b
  end
end

#=> c "example.exs"
{:+, [line: 22], [1, 1]}
2
```
After compiling the module, we can see the results: `{{:+, [line: 22], [1, 1]}}` and `2`, they are both quoted expressions. Remember that number is AST literal so its quoted expressions remains the same as itself.

Combining this fact with the pattern of AST, we can easily do pattern matching to get what we want from the argument for further AST composition.

Keep in mind that code passed into macro is not evaluated/excuted.

### unquote

`unquote` injects quoted expressions into AST returned by `quote`. **You can only use `unquote` inside `quote blocks`**.

To make it easier to understand, you can think **quote/unquote** as **string interpolation**. When you do `quote`, it's like creating string using `""`. When you do `unquote`, it's like injecting value into string by `"#{}"`. However, instead of manipulating string, we are composing AST.

There are two types of unquote:

* Normal unquote

```elixir
data = {1, 2, 3}
quote do
  IO.inspect(unquote(data))
end
```

It looks correct, but when we evaluate the AST, we will get error:

![](http://d.pr/i/7adz+)

How come? It's because we forget an important concept:
> unquote injects AST into AST returned by quote.

`{1, 2, 3}` is not AST literal, so we need to get the quoted expressions. first by using `Macro.escape`.

```elixir
data = {1, 2, 3}
quote do
  IO.inspect(unquote(Macro.escape(data)))
end
```

* Unquote fragment

Unquote fragment is added to support **dynamic generation of functions** and **nested macros**.

```
defmodule MyModule do
  Enum.each [foo: 1, bar: 2, baz: 3], fn { k, v } ->
    def unquote(k)(arg) do
      unquote(v) + arg
    end
  end
end

#=> MyModule.foo(1) #2
#=> MyModule.bar(1) #3
#=> MyModule.baz(2) #4
```
In this example, we use `unquote(k)` as function name to generate functions from keys of a Keyworld list.

You might wonder why we can use `unquote` without `quote`. It's because `def` is macro, its arguments will be quoted automatically as we discussed above.

Besides, we need `quote(v)` inside function body because of scope rule in Elixir:

> for named function, any variable coming from the surrounding scope has to be unquoted inside a function clause body.

### Bind_quoted

`bind_quoted` does two things:

* prevent accidental reevaluation of bindings.

If we have two same `unquote` inside `quote` block, the `unquote` will be evaluated twice, this can cause problem.
We can use `bind_quoted` to fix it:

```elixir
# bad
defmacro my_macro(x) do
  quote do
  	 IO.inspect unquote(x) * unquote(x)
  end
end

# good
defmacro my_macro(x) do
  quote bind_quoted: [x: x] do
  	 IO.inspect x * x
  end
end
```

* Defer the execution of `unquote` via `unquote: false`

`unquote: false` is the default behavior of `bind_quoted`.

The **order of execution** is:

when a macro module is compiled, code in the macro context will run first (`IO.puts 1`). Normal code in `quote` block will not be executed until the returned AST is injected into caller module. However, `unquote` code will "break the wall" and run in macro's context.

Macro module

```elixir
defmodule M do
  defmacro my_macro(name) do
    # macro context
    IO.puts 1

    quote do
      # caller context
      IO.puts 4
      unquote(IO.puts 2)
    end
  end
end

```
Caller Module

```elixir
defmodule Create do
  import M
  IO.puts 3
  my_macro("hello")
end
```
According to the explanation above, we can know the result of the example is: `1 2 3 4`.

If we use `bind_quoted` in the example, the order will change. The `unquote` code will be treated as normal code and run in caller's context. Therefore, the result for the following example is: `1 3 4 2`.

```elixir
defmodule M do
  defmacro my_macro(name) do
    IO.puts 1

    quote bind_quoted: [name: name] do
      IO.puts 4

      def unquote(name)() do
        unquote(IO.puts 2)
        IO.puts "hello #{unquote(name)}"
      end
    end
  end
end
```
```elixir
defmodule Create do
  import M
  IO.puts 3
  my_macro(:hello)
end
```

This is helpful because when we change `my_macro(:hello)` in caller module  to

```elixir
  [:foo, :bar]
  |> Enum.each(&my_macro(&1))
```

Our code will still work because the `each` function is executed before the injected AST.

## How to do experiments

The best way to learn is trial and error, Elixir provides a few functions that can help us:

* IO.inspect

We can use `IO.inspect` to output the details of macro arguments or whatever we want.

* Code.eval_quoted

`eval_quoted` helps to evalute AST we created:

```elixir
data = {1, 2, 3}
ast = quote do
  IO.inspect(unquote(Macro.escape(data)))
end
Code.eval_quoted(ast)

#=> {1, 2, 3}
```

* Macro.to_string

It converts the given quoted expressions to a string.

```
Macro.to_string(ast)
#=> "IO.inspect({1, 2, 3})"
```

* Macro.expand/Macro.expand_once

`Macro.expand` will receive an AST node and recursively expand it.
We can also expand AST once a time using `Macro.expand_once`.

```elixir
ast = quote do: if true, do: IO.puts 1
Macro.expand_once(ast, __ENV__)

{:case, [optimize_boolean: true],
     [true,
      [do: [{:->, [],
         [[{:when, [],
            [{:x, [counter: 0], Kernel},
             {:in, [context: Kernel, import: Kernel],
              [{:x, [counter: 0], Kernel}, [false, nil]]}]}], nil]},
        {:->, [],
         [[{:_, [], Kernel}],
          {{:., [], [{:__aliases__, [alias: false, counter: 0], [:IO]}, :puts]}, [],
           [1]}]}]]]}
```

## Resources

Now we know the basic about metaprogramming in Elixir, it's time to write simple macro, do some experiments and read source code of Elixir or Phoenix.

Also, there are two great resouces:

* [Metaprogramming Elixir](https://pragprog.com/book/cmelixir/metaprogramming-elixir) by [ChrisMcCord](https://twitter.com/chris_mccord)

Great book to read. A lot of practical examples in the book that teach you how to write macros.

* [understanding macro blog series](http://theerlangelist.com/article/macros_1) by [Saša Jurić
](https://twitter.com/sasajuric)
