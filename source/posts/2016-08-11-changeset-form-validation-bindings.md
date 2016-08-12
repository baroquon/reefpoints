---
layout: post
title: "Using Ecto Changesets for HTML input validations"
social: true
author: Nico Mihalich
github: "nicomihalich"
summary: "Leverage the power of Phoenix to utilize your Ecto changeset validations as input validations in your HTML forms"
published: true
tags: elixir, phoenix, HTML, engineering
---

All web applications with user submitted input have some constraints on what input is acceptable.  We as developers have two methods to make sure what the user entered falls within those constraints.

*Client Side Validation* where your application checks form data prior to a network call and prevents the call from happening if it finds the data invalid.

*Server Side Validation* where your application sends data to the server and waits for it to tell you if the data is valid or not.

Both are means to the same end but have their advantages and disadvantages.

## Server Side Validation (Necessary)

### Pros
- Source of truth / "Last line of defense"
- Can be tied to DB logic
- Knows context of the user, session, or other data
- More powerful and secure

### Cons
- Slow to get feedback due to network latency
- Sending the entire form just to get one error

## Client Side Validations (Optional)

### Pros
- Immediate validation
- Preventative
- Semantically accurate
- Nicer feeling feedback due to styling with CSS selectors

### Cons
- Have to keep it in sync with server side
- Brittle
- Not a substitute for server side validation

Generally client side validations are optional, faster, and provide better UX, while server side validations are necessary, stronger, and better tied to your data schema.

Ideally you utilize both, but they're a pain to keep in sync.  In a perfect world your application's back end validations automatically apply to the client. We're going to explore how Phoenix and Ecto give us the power to help us do exactly that.

We can leverage [Phoenix](http://www.phoenixframework.org/) and [Ecto.Changeset](https://hexdocs.pm/ecto/Ecto.Changeset.html) on our front end with just a few lines of code. This doesn't work for everything (uniqueness constraints for example), but there are some nice things we can validate for: min/max, length, and required fields.
Ecto changesets within Phoenix support [validate_length](https://github.com/phoenixframework/phoenix_ecto/blob/master/lib/phoenix_ecto/html.ex#L143), [validate_number](https://github.com/phoenixframework/phoenix_ecto/blob/master/lib/phoenix_ecto/html.ex#L161), [validate_required](https://github.com/phoenixframework/phoenix_ecto/blob/master/lib/phoenix_ecto/html.ex#L114) which correspond to the [HTML input validations](https://developer.mozilla.org/en-US/docs/Web/Guide/HTML/Forms/Data_form_validation) `minlength`/`maxlength`, `min`/`max`, and `required`.

Our goal is to have the validations defined in a schema's changeset function automatically apply the correct HTML input validation to our form.

Let's write some code.

---

## The Code

Let's work with a schema named `foo` with the following changeset function:

```elixir
def changeset(struct, params \\ %{}) do
  struct
  |> cast(params, [:name])
  |> validate_required([:name])
  |> validate_length(:name, min: 2, max: 4)
end
```

By default our form should have something like this:

```
<%= text_input f, :name, class: "form-control" %>
```

Which generates this markup:

```html
<input class="form-control" id="foo_name" name="foo[name]" type="text">
```

It works, but we have to wait for a server round trip to get any validations. We can add client side validation by appending opts by hand like this:

```
<%= text_input f, :name, class: "form-control", required: true, minlength: 2, maxlength: 4 %>
```

Which generates this markup:

```html
<input class="form-control" id="foo_name" maxlength="4" minlength="2" name="foo[name]" required="required" type="text">
```

This is better, but if we ever changed the max to something else we would have to remember to change it in two different places!

We can do better by using [input_validations](https://github.com/phoenixframework/phoenix_ecto/blob/master/lib/phoenix_ecto/html.ex#L113). This function generates the HTML validation attributes from our Ecto changeset for us.

Now we can define our own functions which simply add on those generated input validations to our text and number inputs...

```elixir
alias Phoenix.HTML.Form

def text_input(form, field, opts \\ []) do
  Form.text_input(form, field, opts ++ Form.input_validations(form, field))
end

def number_input(form, field, opts \\ []) do
  Form.number_input(form, field, opts ++ Form.input_validations(form, field))
end
```

Keep the same markup we had initially...

```
<%= text_input f, :name, class: "form-control" %>
```
... and get the semantically correct markup with no changes to the template!

```html
<input class="form-control" id="foo_name" maxlength="4" minlength="2" name="foo[name]" required="required" type="text">
```

## Other validations

This will also work for number validations.  Say our changeset function had a line like

```
|> validate_number(:count, greater_than: 2, less_than: 9)
```

That would give us this markup

```
<input class="form-control" id="foo_count" max="8" min="3" name="foo[count]" required="required" step="1" type="number">
```

---

## Using this in your application

To leverage this in your own Phoenix application, we'll use a module that we will automatically import in all our views.

First define the module with our custom `text_input` and `number_input` functions in `web/views/valid_inputs.ex`

```elixir
defmodule HelloPhoenix.ValidInputs do
  alias Phoenix.HTML.Form

  def text_input(form, field, opts \\ []) do
    Form.text_input(form, field, opts ++ Form.input_validations(form, field))
  end

  def number_input(form, field, opts \\ []) do
    Form.number_input(form, field, opts ++ Form.input_validations(form, field))
  end
end
```

Then in `web/web.ex` just have Phoenix make it available for all our views.

```
def view do
  quote do
    use Phoenix.View, root: "web/templates"

    # Import convenience functions from controllers
    import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

    # Use all HTML functionality (forms, tags, etc)
    use Phoenix.HTML

    # vvvv BEGIN OUR CODE vvvv
    import Phoenix.HTML.Form, except: [number_input: 2, number_input: 3, text_input: 3]
    import HelloPhoenix.ValidInputs
    # ^^^^ END OUR CODE ^^^^

    import HelloPhoenix.Router.Helpers
    import HelloPhoenix.ErrorHelpers
    import HelloPhoenix.Gettext
  end
end
```

And we're done! Now that your inputs have constraints, you can use CSS selectors like `:invalid` and `:required` to make things look a bit nicer for the user.

## Custom Validations

There's also a letter known `pattern` HTML attribute for regex validations.  The JavaScript and Elixir regex engine's are not 100% compatible so it's not supported by default in `input_validations` but we can add it ourselves as an exercise in custom validations.

```
|> validate_format(:email, ~r/.+@.+/)
```

```
def text_input(form, field, opts \\ []) do
  Form.text_input(form, field, extend_opts(form, field, opts))
end

defp extend_opts(form, field, opts) do
  defaults = opts ++ Form.input_validations(form, field)

  case form.source.validations[field] do
    {:format, regex} -> [{:pattern, Regex.source(regex)} | defaults]
    _ -> defaults
  end
end
```

```
<input class="form-control" id="foo_email" name="foo[email]" pattern=".+@.+" type="text">
```

Because we're just composing and calling functions, we can extend our initial implementation easily without having to inherit or monkey patch from an existing View module. Going further, you can tweak your `text_input` and `number_input` to, for example, take an optional `validate` parameter to include opt in/opt out functionality.

## The takeaway

Using simple functions available in Phoenix, your application can automatically apply some of your in-place server side validations to your front end markup to improve your UX in only a few lines of code!
