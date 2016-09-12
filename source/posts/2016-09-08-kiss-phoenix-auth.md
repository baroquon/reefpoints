---
layout: post
title: "KISS by Example: Authorization in Phoenix"
social: true
author: Nico Mihalich
github: "nicomihalich"
summary: "A short example of authorization in Phoenix to show how modules, functions, and mattern matching can easily fill a common web application need."
published: true
tags: engineering, elixir, phoenix
---

## Modules, Functions, and Pattern Matching. Oh My!

As a relatively new Elixir developer, I continue to be impressed by the things the language allows me to accomplish relatively easily.  Features that seemed daunting or time consuming before end up being as simple as: "Modules. Functions. Pattern Matching." Instead of relying on pre-built solutions, a lot of the time your code ends up simpler and easier to reason about if you take advantage of what is in front of you.

## Example: Web App Authorization

Lets pretend we're building a web application where users submit talk ideas for a conference and then the best ones are selected to be included.  Users can submit and edit their own proposals, and admins can mark a talk as `chosen`.  We want to enforce a that rogue user can't select random talks or edit other users' talks to be about nonsense.

Not worrying about how the logic works within the application, lets just lay out some rules for what users can do to talks.


```elixir
defmodule FakeConf.TalkAuthorization do

  alias FakeConf.Talk
  alias FakeConf.User

  # Anyone can go and create a talk
  def authorize(:create_talk, %User{} = _user) do
    :ok
  end

  # Only the user that created a talk can edit it
  def authorize(:edit_talk, %User{} = user, %Talk{} = talk) do
    if owned_by?(user, talk) do
      :ok
    else
      {:error, :unauthorized}
    end
  end

  # Only admins can 'choose' talks
  def authorize(:choose_talk, %User{} = user, %Talk{} = _talk) do
    if user.is_admin do
      :ok
    else
      {:error, :unauthorized}
    end
  end

  defp owned_by?(%User{} = user, %Talk = talk) do
    talk.user_id == user.id
  end

end
```

This keeps our authorization code nice and contained!  When we implement more features, it will be easy to add them to this module.

Now we have these rules, we can use it in our application.  We'll use the new [with](http://elixir-lang.org/docs/stable/elixir/Kernel.SpecialForms.html#with/1) macro here to chain authorization into our existing app logic.

```elixir
defmodule FakeConf.Talks do

  alias FakeConf.Talk
  alias FakeConf.Repo
  alias FakeConf.TalkAuthorization

  def create_talk(%User{} = user, talk_params) do
    talk = %Talk{user_id: user.id}
    with :ok <- TalkAuthorization.authorize(:create_talk, user),
         {:ok, talk} <- Repo.insert(changeset(talk, talk_params)) do
      :ok
    else
      {:error, :unauthorized} -> {:error, :unauthorized}
    end
  end

  def edit_talk(%User{} = user, talk_id, talk_params) do
    with %Talk{} = talk <- Repo.get(Talk, talk_id),
         :ok <- TalkAuthorization.authorize(:edit_talk, user, user),
         {:ok, talk} <- Repo.update(changeset(talk, talk_params)) do
      :ok
    else
      {:error, :unauthorized} -> {:error, :unauthorized}
      {:error, :not_found} -> {:error, :not_found}
    end
  end

  def choose_talk(%User{} = user, talk_id) do
    with %Talk{} = talk <- Repo.get(Talk, talk_id),
         :ok <- TalkAuthorization.authorize(:choose_talk, user, talk),
         {:ok, talk} <- Repo.insert(changeset(talk, %{chosen: true})) do
      :ok
    else
      {:error, :unauthorized} -> {:error, :unauthorized}
      {:error, :not_found} -> {:error, :not_found}
    end
  end
end
```

Super simple, clean, and easy to read because we're combining functions that are organized in modules.  Nothing crazy happening.

This isn't just an example of how to do authorization. When you're looking to add a feature to your application, consider it might be simpler than you think when you take advantage of the tools you have available.
