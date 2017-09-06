---
layout: post
title: “Adding an Email Verification Flow With Phoenix”
social: true
author: Alex Garibay
twitter: "_alexgaribay"
github: alexgaribay
summary: “Verifying a user email address is a common feature in modern web applications. Learn how to add email verification to your application in Elixir and Phoenix.”
published: true
tags: engineering, elixir, phoenix
---

![An example of a verification email](https://i.imgur.com/8uagm5W.png)

Many modern web applications require users to verify their email address at one point or another. This is especially important when you have a billing process that sends receipts to your users. We can easily add this feature to applications with Elixir and Phoenix.

## The Basic Flow
We’ll assume that the row that has the email address also has a `verified` boolean field or something equivalent.

1. A user registers or adds an email to their account
2. Your application generates a unique token that is tied to the user
3. An email is sent to the user’s email address with a link to click
4. User navigates to link in their browser and has their email address verified

## The Verification Endpoint
Let’s stub out some code for the new route. Create a new action in your controller:

```elixir
defmodule MyAppWeb.UserController do
  use MyAppWeb, :controller

  # Your other actions

  def verify_email(conn, params) do
    # We'll update this later
  end
end
```

Tie the action to a route in your router:

```elixir
scope "/", MyAppWeb do
  # ...
  get "/verify", UserController, :verify_email
end
```

## Generating a Unique Token
When you generate your token, you’ll want to make sure that the token doesn’t leak account information during the verification process as well as having the token expire after a certain duration. For us, Phoenix already comes with a module to help us in this area; [Phoenix.Token](https://hexdocs.pm/phoenix/Phoenix.Token.htm). We can use `Phoenix.Token` to create a signed token that can be tied to a specific user and can enforce an expiration.

Here’s how we can generate the token with [Phoenix.Token.sign/4](https://hexdocs.pm/phoenix/Phoenix.Token.html#sign/4):

```elixir
defmodule MyApp.Token do
  @moduledoc """
  Handles creating and validating tokens.
  """

  @account_verification_salt "account verification salt"

  def generate_new_account_token(%User{id: user_id}) do
    Phoenix.Token.sign(MyAppWeb.Endpoint, @account_verification_salt, id)
  end
end
```

You’ll want to update your user registration endpoint to generate the token and email the user with the link. You can use your router’s path helpers to create the link.

```elixir
defmodule MyAppWeb.UserController do
  use MyAppWeb, :controller

  def create(conn, params) do
    # ...

    token = MyApp.Token.generate_new_account_token(user)
    verification_url = user_url(conn, :verify_email, token: token)
    MyApp.Notifications.send_account_verification_email(user, verification_url)

    # ...
  end
end
```

## Verifying the token
Now that we can send a signed token to a user, we need to verify the token and then mark the user as verified. Let’s go back and update our `UserController` and `Token` modules to verify our signed token. We will use [Phoenix.Token.verify/4](https://hexdocs.pm/phoenix/Phoenix.Token.html#verify/4) to verify our tokens.


```elixir
defmodule MyApp.Token do
  # ...

  def verify_new_account_token(token) do
    max_age = 86_4000 # tokens that are older than a day should be invalid
    Phoenix.Token.verify(MyAppWeb.Endpoint, @account_verification_salt, token, max_age: max_age)
  end
end


defmodule MyAppWeb.UserController do
  use MyAppWeb, :controller

  # ... Your other actions

  def verify_email(conn, %{"token" => token}) do
    with {:ok, user_id} <- MyApp.Token.verify_new_account_token(token),
         {:ok, %User{verified: false} = user} <- MyApp.Users.by_id(user_id) do
      MyApp.Accounts.mark_as_verified(user)
      render(conn, "verified.html")
    else
      _ -> render(conn, "invalid_token.html")
    end
  end
  def verify_email(conn, _) do
    # If there is no token in our params, tell the user they've provided
    # an invalid token or expired token
    conn
    |> put_flash(:error, "The verification link is invalid.")
    |> redirect(to: "/")
  end
end
```

## Wrap Up
Leveraging Phoenix’s Token module, we created a straightforward method of adding a user email verification feature.
