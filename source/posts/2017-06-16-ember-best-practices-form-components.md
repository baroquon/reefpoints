---
layout: post
title: "Ember Best Practices: Reducing CRUD complexity with components"
social: true
author: Nico Mihalich
github: nicomihalich
summary: "Reduce your Ember CRUD code with form components"
published: true
tags: Ember, Best Practices
---

A fair amount of web applications can be boiled down to simple CRUD (Create, Read, Update, Delete).  Thankfully Ember/Ember Data/JSON API make doing this pretty trivial.  Let's fake out a little example of the create template for our fancy new *MyWidgets™* application.

```
<form>
  <label for="widget-name">Name</label>
  {{one-way-input model.name id="widget-name" update=(action (mut model.name))}}

  {{one-way-checkbox model.isFancy id="widget-is-fancy" update=(action (mut model.isFancy)}}
  <label for="widget-is-fancy">Fancy?</label>

  <button type="submit" {{action "save"}}>
    Create Widget
  </button>
</form>
```

Great! We have inputs for name, if it's fancy or not, and a save button.


Now let's build a template for editing an existing widget.

```
<form>
  <label for="widget-name">Name</label>
  {{one-way-input model.name id="widget-name" update=(action (mut model.name))}}

  {{one-way-checkbox model.isFancy id="widget-is-fancy" update=(action (mut model.isFancy)}}
  <label for="widget-is-fancy">Fancy?</label>

  <button type="submit" {{action "save"}}>
    Update Widget
  </button>
</form>
```

### Changing requirements

As we're doing this we might realize we forgot to add the description field for our widget! No problem, we just have to add it back to both forms.

... wait a minute both are basically same and we're making the same edits! Maybe we realized this and copy/pasted; but even that should have set off a red flag.

## Let's make it better

Let's move that template into a component, with one small change.

```handlebars
<form>
  <label for="widget-name">Name</label>
  {{one-way-input model.name id="widget-name" update=(action (mut model.name))}}

  {{one-way-checkbox model.isFancy id="widget-is-fancy" update=(action (mut model.isFancy)}}
  <label for="widget-is-fancy">Fancy?</label>

  {{yield}}
</form>
```

Since our save buttons are different, we can yield the area where the buttons are and add our different buttons in the create and edit templates.  Now our create form looks like this

```handlebars
{{#widget-form model=model}}
  <button type="submit" {{action "save"}}>
    Create Widget
  </button>
{{/widget-form}}
```

And edit like this:

```handlebars
{{#widget-form model=model}}
  <button type="submit" {{action "save"}}>
    Create Widget
  </button>
{{/widget-form}}
```

This is good, but we can do better with some Ember Data properties.

## Let's make it even better

Since the model hook from our new route is returning a new widget, and the edit is returning an existing one, we can leverage some built-in Ember Data functionality to clean our forms up more: [isNew](https://www.emberjs.com/api/data/classes/DS.Model.html#property_isNew)

```handlebars
<form>
  <label for="widget-name">Name</label>
  {{one-way-input model.name id="widget-name" update=(action (mut model.name))}}

  {{one-way-checkbox model.isFancy id="widget-is-fancy" update=(action (mut model.isFancy)}}
  <label for="widget-is-fancy">Fancy?</label>

  <button type="submit" {{action "save"}}>
    {{#if model.isNew}}
      Create Widget
    {{else}}
      Update Widget
    {{/if}}
  </button>
</form>
```

```handlebars
{{widget-form model=model save=(action "save")}}
```

And edit like this:

```handlebars
{{widget-form model=model save=(action "save")}}
```

(They're still identical but much more DRY, and you can imagine some different CSS/HTML wrapping them in your create/edit pages.  Also now you can drop a form wherever you need it!)

## Takeaways

This is a fairly simple example, but thinking about where and how your application manipulates your models, and using components to encapsulate functionality, can save you from making double edits, or forgetting to make changes in one place and not another and introducing a bug.  Your forms might have more complicated actions for save, or different inputs and layouts, but you will save time by [taking the time to do things right](https://xkcd.com/1691/).
