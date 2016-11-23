---
layout: post
title: "Making a DDAU checkbox list in Ember.js"
social: true
author: Nico Mihalich
github: nicomihalich
summary: "Use Data Down, Actions Up to create a simple Checkbox List UI element in Ember"
published: true
tags: engineering, ember, javascript
comments: true
---

## Data Down, Actions Up (A refresher)

An important part of creating stable, maintainable Ember applications is following the Data Down, Actions Up (DDAU) paradigm.  This means that your data comes in at the route level and is displayed further down in your UI (by templates and components), while when you want to manipulate that data, you trigger an action which gets sent back up to the route that manipulate the data at its source.  This makes your application simple and easy to reason about because there is a single source of truth for your data and the route that manipulates the data.

## Okay... so?

So, it's hockey season! Let's finally build that favorite player voting app you've always wanted. We'll display a list of players via a list of checkboxes and have the user select which ones they like.  Our input will be a list of strings, and we want the output to be another list of strings. Following DDAU, ideally we want our checkboxes to not actually manipulate a `selected` value directly, but send an action back up which manipulates our model and marks the player as `selected`. (We'll leverage [One Way Controls](https://github.com/DockYard/ember-one-way-controls) for that).

## Setup

Model:
Our model hook is dead simple:

```javascript
model() {
  return [];
}
```

Also we'll need some options to select from.  Let's put that in the controller:

```javascript
import Ember from 'ember';

const { Controller, set } = Ember;

export default Controller.extend({
  init() {
    this._super(...arguments);
    set(this, 'playerOptions', [
      'Phil Kessel',
      'Sidney Crosby',
      'Tyler Seguin',
      'Steven Stamkos',
      'Connor McDavid',
      'Patrick Kane'
    ]);
  }
});
```

And a simple template:

```handlebars
<div>
  <h2>Pick your favorites</h2>
  <ul>
    {{#each playerOptions as |player|}}
      <li>
        {{!TODO Checkbox}}
        {{player}}
      </li>
    {{/each}}
  </ul>
</div>

<div>
  <h2>You picked</h2>
  <ul>
    {{#each model as |player|}}
      <li>{{player}}</li>
    {{/each}}
  </ul>
</div>
```

## Checkboxes

Now we have some options, and a place to select them into.  Let's write the checkbox logic!  The API for a checkbox looks something like:

```handlebars
{{one-way-checkbox selected update=(action "someAction")}}
```

Where selected is a boolean.

For our use case, the checkbox should be selected when the player is in the model. Note our input and output are both lists of strings, no `selected` attribute. So how do we mark it as selected if we don't store it?

## Quick detour into helpers!

We want to have `selected` in our template be true when an item is in an array.  We can write a [helper](https://guides.emberjs.com/v2.9.0/templates/writing-helpers/) that does this for us which we can use in the template to return our `selected` boolean value:

```javascript
import Ember from 'ember';

const { Helper: { helper } } = Ember;

export function includes([haystack, needle]) {
  return haystack.includes(needle);
}

export default helper(includes);
```

This enables us to write

```handlebars
{{one-way-checkbox (includes model player) ...}}
```

It's also useful in that if your model returns some options, the template is reactive to that and automatically marks them as selected because the helper is computing it from the higher up data flowing into it.

Cool!

## Actions

So far so good, but if we click on the checkbox... it doesn't do anything.  We'll need an update action, which we want in our route (using [ember-route-action-helper](https://github.com/DockYard/ember-route-action-helper)).

```javascript
  actions: {
    togglePlayer(player, checked) {
      let model = get(this, 'currentModel');
      if (checked) {
        model.pushObject(player);
      } else {
        model.removeObject(player);
      }
    }
  }
```

## Finally

Now we can insert a checkbox using our `includes` helper and action.

```handlebars
  {{one-way-checkbox (includes model player)
    update=(route-action "togglePlayer" player)}}
```

And we're done! [Here's a demo](https://ember-twiddle.com/da6865aefe607e9deb460b5f29e20b0b).

I hope this demonstrates a practical example of DDAU in Ember to build a pretty common UI element.
