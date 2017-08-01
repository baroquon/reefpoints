---
layout: post
title: "SVG Assets in PWAs"
social: true
author: Cory Tanner
twitter: "ctannerweb"
github: 
summary: "With a new exciting way to build web applications, we need to rethink our development process."
published: true
tags: PWA, Engineering
---
Progressive Web Apps are a hot topic currently and chances are there will be a talk on them at most web conferences. With a new exciting way to build web applications, we need to rethink our development process. Let’s dive into managing SVG assets within PWAs!

## Changing our old method
For a while now our go-to method for including SVGs in our apps has been the external `<use xlink:href="foo.svg#bar">` which you can read up on over at [css-tricks: SVG `use` with External Reference, Take 2](https://css-tricks.com/svg-use-with-external-reference-take-2/).

This worked great before HTTP2 when assets were pulled from the server one at a time. One optimized SVG file was pulled down from the server and individual SVGs would be linkable with IDs inside that one SVG file. This was before PWA’s cached your assets per page. With this method in a PWA you would be downloading one large SVG file for every page. Not very performant.

Now, one pull request from the server can include multiple files with HTTP2. Having individual SVG assets now makes sense: you don’t need to pull down all your SVG assets at once. After your SVG assets are in the browser, they will be cached.

## On to using SVGJar
The bird's eye view description of this method is that we include every SVG on our app inline. This is done with the plugin [Ember SVGJar](https://www.npmjs.com/package/ember-svg-jar).  This, in a sense, gives you an icon font set, but purely done with SVG.

There are some upfront advantages of having individual inline SVG files with SVGJar that should be outlined:
- SVG assets used with CSS background property
- SVG assets are included inline so you have full creative control over the SVG with CSS styling
- Most performant way of including optimized SVG’s on a page

You can read up on how the plugin works in detail, but we still organize our SVG assets in an asset folder that is linked to SVGJar. The plugin will then take those SVG assets and inject them into the page where you include the handlebar helper.
```
{{svg-jar "asset-name"}}
```

The result is that the Ember app sees what SVG’s are needed and, thanks to SVGJar, pulls the asset from the asset folder, injecting the SVG code directly into the HTML before it gets sent to the server and then browser.

Simple and customizable inline SVG’s make for a great environment for SVG creativity and gets out of the way of the PWA. What more could you ask for?

Want to talk more about PWAs? [Drop us a line](https://dockyard.com/contact/hire-us).
