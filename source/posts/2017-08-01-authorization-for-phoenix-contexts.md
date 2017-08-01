---
layout: post
title: "Authorization Considerations For Phoenix Contexts"
social: true
author: Chris McCord
twitter: "chris_mccord"
github: chrismccord
summary: "Should authorization be handled in the Web layer or within the context? Let's find out which approach is better and when."
published: true
tags: elixir, phoenix, authorization
---

With the recent [Phoenix 1.3 release](http://phoenixframework.org/blog/phoenix-1-3-0-released), Phoenix introduced *Contexts*, which are dedicated modules that expose and group related functionality. One frequent question that has come up is where to handle authorization for domain operations. Should authorization be handled in the Web layer at the controller, or within the context? Both are valid approaches, so let's find out which approach is better and when.

There are are a few things to consider when determining where to handle authorization. Decoupling authorization from the contexts can allow you to apply different business rules on a case-by-case basis for underlying domain operations, but in some cases, enforcing a business rule in a single place, uniformly, is more desirable.

Let's walk through a couple scenarios with code. Imagine the `CMS` system from the [phoenix context guide](https://hexdocs.pm/phoenix/contexts.html). In this system, we have `Accounts.User`'s and `CMS.Author`'s, and we chose to authorize CMS page updates in the controller before allowing `CMS.update_page/2` to be called:

```elixir
  plug :authorize_page when action in [:edit, :update, :delete]
  ...
  defp authorize_page(conn, _) do
    page = CMS.get_page!(conn.params["id"])

    if conn.assigns.current_author.id == page.author_id do
      assign(conn, :page, page)
    else
      conn
      |> put_flash(:error, "You can't modify that page")
      |> redirect(to: cms_page_path(conn, :index))
      |> halt()
    end
  end
```

Our authorization here enforces the rule that only page owners are allowed to update their pages. Now, imagine we continue building our CMS, and we introduce a `Staff.PageController` where `%Staff.User{}`'s of our company can moderate published content. If we had enforced our authorization rules in `CMS.update_page/2`, we would not be able to expose another endpoint for staff members to moderate posts without either adding new functions to the CMS, or making the caller aware of the internal authorization details and have them pass the owner in themselves. We may also need to make the CMS staff-user aware, which adds more coupling. In cases where you have domain operations that you want carried out, but under different policy scenarios, decoupling authorization makes the most sense.

Having said that, now let's imagine a `Warehouse` context where we allow businesses to update their warehouse inventory. Imagine we have an HTML interface, a REST API, and long-running processes which consume CSV data from warehouses (common in the industry). Under this scenario, we have multiple different paths of user input, all being applied to the same domain action, like `Warehouse.increment_quantity`. This function must be an atomic, performant operation. For usecases such as processesing batched CSV data, we don't want to fetch the entire product only to authorize the organization against it for atomatically updating a single field. Instead, we would need only the `product_id` from user input, which we can authorize within the query itself as we pass through each CSV row. From a performance and code re-use perspective, pushing authorization logic into the Warehouse where only businesses that own a particular product record can update it makes sense. The code using Ecto would look something like this: 

```elixir
defmodule MyApp.Warehouse do

  def increment_quantity(product_id, %Organization{} = org, amount) do
    from(p in Product,
      where: p.id == ^product_id and p.org_id == ^org.id),
      [inc: [quantity: amount]], returning: [:quantity])
    |> Repo.update_all()
    |> case do
      {1, [%Product{quantity: new_quantity}]} ->
        {:ok, new_quantity)}
      {0, []} -> {:error, :unauthorized}
    end
  end
end
```

We have the option of enforcing the rules at each HTML controller, API controller, and CSV task, but we would need to duplicate the logic and make sure it stays up-to-date with our business rules in each location. However, in some cases performance dictates that we must move the authorization into the query itself, making the context the only suitable place for authorizing the operation.

For code-reuse and maintainability when doing authorization outside of the context, we at DockYard like to expose plain old modules:

```elixir
defmodule MyApp.Authorizer do

  def authorize(:update, %CMS.Page{}, %Accounts.User{}) do
    if page.user_id == user.id or page.organization_id == user.organization_id do
      :ok 
    else
      {:error, :unauthorized}
    end
  end

  def authorize(:update, %CMS.Page{}, %Staff.User{}) do
    :ok
  end
end
```

Which we can then call in the controller:

```elixir
defmodule CMS.PageController do
  
  def update(conn, %{"id" => id, "page" => page_params}, current_user) do
    with page = CMS.get_page!(id),
         :ok <- Authorizer.authorize(:update, page, current_user),
         {:ok, page} <- CMS.update_page(page, page_params) do
    
      conn
      |> put_flash(:info, "Page Updated")
      |> redirect(to: cms_page_path(conn, :show, page)
    end
  end
end

```


This allows us to wrap up the business rules inside a module to be called from multiple code paths. It also keeps our contexts decoupled from business rules they don't need to care about, such as super user or staff users. You can read more about this approach in a [post by our own Nico Mihalich](https://dockyard.com/blog/2016/09/08/kiss-phoenix-auth)

As we can see, both options are completely valid, and in some cases one may make more sense over the other given your use case. Authorizing at the integration layer with your context gives you the most flexibility, but you need to take care to ensure business rules are applied at each integration point. Authorizing in the context allows you to apply business rules uniformely under all usecases, and at times is the only option when high throughput operations are required.
