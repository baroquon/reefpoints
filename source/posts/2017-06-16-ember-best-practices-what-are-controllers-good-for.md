---
layout: post
title: "Ember Best Practices: What are controllers good for?"
social: true
author: Marten Schilstra
twitter: "martndemus"
github: martndemus
summary: "What are the responsibilities of Controllers? Should I still use Controllers? Let's find out!"
published: true
tags: Engineering, Ember, Best Practices
---

There possibly is a lot of confusion around what Ember's Controllers are good for. I've seen some situations where Controllers have been avoided at all cost, where everything has been delegated to either the corresponding Route or to Components. I've also seen the flip side, where a Controller was used like a Component.

What should you do and what shouldn't you do with them?

## Don't not use controllers
Let's get the controversy out of the door. Do use your Controllers, it's still there, not deprecated and you can use it for great good, you just need to know what they can and can't do.

First of you need to know that a Route's Controller is a singleton and thus it will keep state between activations, for example when a user leaves the Route and then re-enters it. Therefore you can't keep any UI state on a Controller, for example a `isExpanded` variable for keeping track of expanded/collapsed state.

### What can you do with a Controller?
Well the first thing you can do is add an `alias` Computed Property (CP) to give the `model` property a more descriptive name. If you return multiple Models using `RSVP.hash` from a Route's model hook I prefer using aliases instead of setting it up in the Route's `setupController` hook.

Next to alias CP's, you can also have any other CP's, but only if those CP's derive its state from the Model. The same principle goes for actions: put all the actions that update the Model on the Controller, no need to use ember-route-action-helper for that. In fact, most of those actions end up  becoming  [ember-concurrency](http://ember-concurrency.com) tasks, because they tend to be of an async nature.  

You can let actions trigger transitions too, but only do that if you can't use a `link-to` component, for example transitioning after having submitted a form.

 Let's look at a simple (contrived) example:

```javascript
import Controller from '@ember/controller';
import { computed, get } from '@ember/object';
import { alias } from '@ember/object/computed';

export default Controller.extend({
  user: alias('model'),

  fullName: computed('user.{firstName,lastName}', function() {
    return `${get(this, 'user.firstName')} ${get(this, 'user.lastName')}`;
  }),

  actions: {
    updateUserModel(userAttributes) {
      let user = get(this, 'user');
      setProperties(user, userAttributes);
      return user.save()
        .catch(() => user.rollbackAttributes())
        .then(() => this.transitionToRoute('index'));
    }
  }
});
```

Here you can see that I aliased the Model to give it a more useful name and then created a CP that derives from the user Model. Lastly, there is an action that updates the user Model, saves it, and then transitions to the `index` Route.

### What about Query Parameters?
Good question! You should treat Query parameters like the state from your Model. So you can derive Computed Properties from it and update the Query Parameters using actions.

### But I absolutely need UI state on my Controller
I advise against it, but if you really need to have some state on the Controller that does not derive from the Model or a Query Parameters, and it's not intended to stick around between transitions, then you should use the Route's `setupController` or `resetController` hook to reset the state between transitions.

## In conclusion
Use Controllers as an extension of the model loaded from the Route. Derive state from the Model or Query Parameters using Computed Properties. Update the Model or Query Parameters using actions. Avoid putting any state on the Controller that doesn't derive from either the Model or Query Parameters. 

Have a more complex Ember issue? [Contact us](https://dockyard.com/contact/hire-us). 
