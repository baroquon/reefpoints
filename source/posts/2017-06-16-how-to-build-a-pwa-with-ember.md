---
layout: post
title: "How to build a Progressive Web App with Ember"
social: true
author: Marten Schilstra
twitter: "martndemus"
github: martndemus
summary: "This tutorial will go through the basics of making your Ember app home screen installable and available offline."
published: true
tags: Ember, PWA
---

To make any app a Progressive Web App (PWA) you need it to do two things: you need to make it installable to the home screen and make the app available offline in some degree using a Service Worker.

It's not too hard nowadays to transform an Ember app into a basic PWA.  In true Ember fashion there are addons for both things needed to make it a PWA. For basic PWA functionality you only need to install a few addons and configure them.

## Making the app installable
Start with installing the [ember-web-app](https://github.com/san650/ember-web-app) addon: `ember install ember-web-app`. Then update the generated `config/manifest.js` file with your app's details.

The ember-web-app addon will use your configuration `manifest.js` to generate a web app manifest and add it to your build. If you now build and deploy your app, then visit it in a browser that supports web app manifest, you can install it to the home screen of that device. It also supports generating meta tags for Safari home screen installs out of the box.

## Making the app available offline
To add a Service Worker for offline capability start with [ember-service-worker](http://github.com/dockyard/ember-service-worker), this addon will take care of building and installing a Service Worker script along with your Ember app. 

Next you will need a few of ember-service-worker's plugin addons to add actual functionality. The first one is [ember-service-worker-index](http://github.com/dockyard/ember-service-worker-index), this will take care of making your `index.html` available offline. For most apps this plugin should work out of the box. If it doesn't, you can configure the plugin in your `ember-cli-build.js` file, the options you can configure are documented in the plugin's readme.

The second plugin you will need is [ember-service-worker-asset-cache](http://github.com/dockyard/ember-service-worker-asset-cache), this will take care of making the files in the `assets` folder of your build available offline. Again, by default you do not need to configure anything, this addon will take care of making your assets available offline. However, if you have a lot of assets you might want to exclude some of the non-essential assets, as this plugin will aggressively try to cache a copy of the asset files when the Service Worker is installed, see the readme of the plugin to see how you can exclude some files.

If you did exclude some assets there is a third plugin you might want to install: [ember-service-worker-cache-first](http://github.com/dockyard/ember-service-worker-cache-first). This plugin will lazily make the configured assets available offline when they are requested.  This plugin does not work out of the box, so you will have to configure it to your app's specifics in `ember-cli-build.js`.

To put it all together, here's an example `ember-cli-build.js` file to give you an idea how you can configure your app:

```javascript
const EmberApp = require('ember-cli/lib/broccoli/ember-app');

module.exports = function(defaults) {
  let app = new EmberApp(defaults, {
    'asset-cache': {
      exclude: [
        'assets/images/**/*',
        'assets/fonts/**/*'
      ]
    },
    'esw-cache-first': {
      patterns: [
        '/assets/images/(.+)',
        '/assets/fonts/(.+)'
      ]
    },
  });
}
```

## Conclusion
There you have it. If you followed along with this guid your app should now be installable on the home screen and running a Service Worker that will take care of making your app's assets available offline. Ideas for next steps are making your app's data available offline using LocalStorage and/or IndexedDB, or sending push notifications to your users using the Service Worker's push notification API.
