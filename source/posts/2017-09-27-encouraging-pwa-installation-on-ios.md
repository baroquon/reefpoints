---
layout: post
title: "Encouraging iOS users to install your Progressive Web Apps in Ember"
social: true
author: Scott Batson
twitter: "@ScottJBatson"
github: sbatson5
summary: "PWA installation is simple on modern Android devices, but driving installation and the native experience is a larger hurdle on iOS."
published: true
tags: PWA, ember, Engineering
---

![Imgur](https://i.imgur.com/XQEysi6.jpg)

We have spent a lot of time over the past few months talking about [Progressive Web Apps](https://dockyard.com/blog/categories/pwa) on our blog and how you can [build them easily with Ember](https://dockyard.com/blog/2017/07/20/how-to-build-a-pwa-with-ember). It's no secret that we see the value in PWAs and the [business problems they can solve](https://dockyard.com/blog/2017/05/03/five-business-problems-pwas-solve). However, we still have one hurdle to overcome with adoption: iOS.

## Installing PWAs
If you use an Android device, you have probably noticed that PWAs automatically prompt you to add the application to your homescreen but iOS still doesn't do this. If you're unaware of the differences, [mobile Safari does not support some key PWA features](https://dockyard.com/blog/2017/07/13/safari-ios-and-progressive-web-apps). [This is changing quickly, however](https://webkit.org/status/#specification-service-workers); the most recent release of iOS allows PWAs saved to your homescreen to be launched as a standalone application. This means your web app can launch without the cumbersome Safari UI. Unfortunately, one key thing is still missing: prompting the user to install the app.

## Adding to Homescreen on iOS
The key to success for Progressive Web Apps is adoption--if you want to compete with native applications, you want the user to install and launch the app the same way. On a recent client project, we thought a lot about client adoption on iPhone (a large percentage of our user base) and how we could encourage users to install our app. We decided to go with a modal prompt with clear and easy steps to install the app.

![Add to homescreen modal](https://i.imgur.com/gOZBWBH.png)

## When to prompt
The first issue we had to solve was when to show this modal. It goes without saying that this modal is not useful unless you are on an iPhone or iPad--so that should be the first thing we test. We can do this easily with the `window.navigator` API.

```javascript
needsToSeePrompt() {
  return ['iPhone', 'iPad', 'iPod'].includes(navigator.platform);
}
```

We can then call this method when our application route activates--that way the user sees this modal no matter which route they load. However, you may not want to inundate your users with these prompts every time they launch the app (after all, they may not actually _want_ your app on their homescreen). We decided to only show this prompt for logged in users (since our app required authentication) and to only show it once every two weeks.

We updated our function to be aware of the last time the user saw a prompt using [ember-moment](https://github.com/stefanpenner/ember-moment).

```javascript
needsToSeePrompt(user) {
  let today = moment();
  let lastPrompt = Ember.get(user, 'lastSeenPrompt');
  let days = today.diff(lastPrompt, 'days'); // the number of days between now and the last prompt
  let isApple = ['iPhone', 'iPad', 'iPod'].includes(navigator.platform);
  return (isNaN(days) || days > 14) && isApple;
}
```

Now on our `application` route, we can check to see if we have a logged in user and if we do, we'll perform this check:

```javascript
activate() {
  let currentUser = Ember.get(this, 'currentUser'); // a service we have to fetch user
  if (currentUser) {
    if (this.needsToSeePrompt(currentUser)) {
      Ember.set(currentUser, 'lastSeenPrompt'. moment()); // set current time for prompt
      /* we had a specific route for showing the modal
      but this could be any action to prompt the user */
      this.transitionTo('add-to-homescreen');
    }
  }
}
```

![Installing](https://i.imgur.com/7Zz2hEr.png)

## When not to prompt
We've handled showing the prompt on iOS devices and not on desktop or Android. Now we have to solve the inverse case: not showing the prompt when the user has launched the app from their homescreen. It wouldn't make much sense to keep showing them the prompt if they already followed our instructions. Unfortunately, there are two cases we need to handle: users with newer iOS versions and legacy users.

## Standalone apps
On newer versions of iOS, PWAs can be launched as a standalone app (this is controlled by our app's manifest where `display` is set to `standalone`). Standalone apps give a more "native" feel, as they are launched just like any app and not in the browser, hiding the Safari UI. Luckily, seeing if an app is standalone is fairly easy with the `window.navigator` API. We can update our prompt method to handle this case:

```javascript
needsToSeePrompt(user) {
  if (navigator.standalone) {
    return false;
  }
  let today = moment();
  let lastPrompt = Ember.get(user, 'lastSeenPrompt');
  let days = today.diff(lastPrompt, 'days');
  let isApple = ['iPhone', 'iPad', 'iPod'].includes(navigator.platform);
  return (isNaN(days) || days > 14) && isApple;
}
```

`window.navigator.standalone` returns a boolean that can drive our logic. It will be `undefined` on older versions of Safari, which will resolve to a falsy value.

## Non-standalone apps
Finally, we handle the case where our phone does not support standalone apps. `window.navigator.standalone` will return `false` when launching the app from our homescreen opens our browser. However, we can specify a `start_url` in our app's manifest (in Ember, this is defined in `config/manifest.js`). We simply add a query param:

```javascript
'use strict';

module.exports = function() {
  return {
    name: 'Mobile Dockyard',
    short_name: 'Mobile Dockyard',
    description: 'Dockyard - but mobile',
    start_url: '/?standalone', // our query param
    display: 'standalone',
    background_color: '#F6FEFF',
    theme_color: '#F6FEFF',
    icons: [...]
  };
}
```

Now we will know if the user launches the application into the browser from their homescreen. We can make one last update to our `needsToSeePrompt` method to check this:

```javascript
needsToSeePrompt(user, standalone) {
  // we pass in the result of our query-param to this method
  if (navigator.standalone || standalone) {
    return false;
  }
  let today = moment();
  let lastPrompt = Ember.get(user, 'lastSeenPrompt');
  let days = today.diff(lastPrompt, 'days');
  let isApple = ['iPhone', 'iPad', 'iPod'].includes(navigator.platform);
  return (isNaN(days) || days > 14) && isApple;
}
```

## Testing this
You might be wondering how to test this behavior; especially considering `window.navigator.platform` is a read-only property. To get around this, you can invoke the `__defineGetter__` method to stub your `platform`.

```javascript
test('logging in for first time prompts add-to-homescreen on iPhone', function(assert) {
  window.navigator.__defineGetter__('platform', () => {
    return 'iPhone';
  });
  visit('/');

  andThen(function() {
    assert.equal(currentURL(), '/add-to-homescreen'); // the name of our modal route
  });
});
```

It is as simple as that to stub the `platform` call and test the behavior. However, be careful because this will update the `platform` for your _entire test suite_. To get around this, save the value of the original `platform` in your `beforeEach` hook and reset it in your `afterEach`.

```javascript
let originalPlatform;

moduleForAcceptance('Acceptance | add to homescreen', {
  beforeEach() {
    originalPlatform = window.navigator.platform;
  },

  afterEach() {
    window.navigator.__defineGetter__('platform', () => {
      return originalPlatform;
    });
  }
});
```

That will reset it after each test in this module and shouldn't interfere with the rest of your test suite.

Until iOS automatically recognizes and prompts the user when a PWA is detected, finding workarounds for engagement is your best bet. Luckily, modern browsers make it easy to see and track which users are running your app in `standalone` mode, allowing you to take the proper action.
