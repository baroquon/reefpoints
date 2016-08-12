---
layout: post
title: "Pieces of Ember: Part 2"
author: "Heather Brysiewicz"
twitter: "caligoanimus"
github: "hbrysiewicz"
published: true
tags: ember, javascript
summary: "How to leverage the ember ecosystem without the ember ecosystem"
---

This is part 2 of a 3 part series on pieces of [Ember][ember]. It is also a continuation or elaboration of a lightning talk I gave at the July [SanDiego.js Community][sandiegojs] event which can be found [here][sdjs-talk].

* Part 1: RSVP and Broccoli
* Part 2: Route-recognizer and Router
* Part 3: Handlebars and HTMLBars

To review, the pieces of the ember ecosystem that are covered in this series are:

* [tildeio/rsvp.js][rsvp]
* [broccolijs/broccoli][broccoli]
* [tildeio/route-recognizer][route-recognizer]
* [tildeio/router.js][router]
* [wycats/handlebars.js][handlebars]
* [tildeio/htmlbars][htmlbars]

These pieces of ember would be able to provide any JavaScript project with:

* Promises
* Build tools
* Routing capabilities
* View templating
* Templating with Virtual DOM

All without the need to buy into the entire ember ecosystem.

### [tildeio/route-recognizer.js][route-recognizer]

TL;DR The full example I'm going to review can be found at [hbrysiewicz/route-recognizer-example][route-recognizer-example].

Route-recognizer handles parsing URLs for single page apps. It ships with every build of ember and is currently undergoing a rewrite by <a href='//nathanhammond.com/'>Nathon Hammond</a> that will make it more performant. As one would expect, route-recognizer could be used in practically any JavaScript application to map URLs to different handlers.

The current version of route-recognizer uses regular expressions to match static segmants, dynamic segmants, and globs. The source for this solution is relatively straight forward. The new version of [route-recognizer][nh-route-recognizer] written by Nathan Hammond uses a nondeterministic finite automata (NFA) to handle the route mapping which ends up being extremely performant. It simplifies the entire process by using one data structure and one transition function to implement. So now, instead of loading up the app with an entire route-recognizer that serializes and deserializes routes, the app now only needs the NFA representation of the routes and a transition method.

The route-recognizer alone is pretty bare. It does one thing and does it well. There is a bit of work that needs to be done to manage the URL state, recognize a URL change, and manage the transitions between states. This is where something like a router and a URL listener would come in handy. The router would be that more comprehensive layer responsible for implementing the route-recognizer.

Let me show you how you would get it working in a project outside of Ember though, because that's the fun stuff and really what makes this post worthwhile.

For this example I'm using a build process similar to the one discussed in the broccoli section except I've added the ability to use named amd modules. The example project for the following code can be found at [hbrysiewicz/route-recognizer-example][route-recognizer-example]. This example is only going to cover the route-recognizer pieces.

```js
// router.js

import RouteRecognizer from 'route-recognizer';
import postsHandler from 'routes/posts';
import postHandler from 'routes/post';

let router = new RouteRecognizer();

router.add([{ path: "/posts", handler: postsHandler }]);
router.add([{ path: "/posts/:post_id", handler: postHandler }]);

export default router;
```

By including route-recognizer in my project I can now map specific URLs to handlers. Now if I include this router in my project and call the `recognize()` method on the router, I will get back the `handler` and any parameters captured by dynamic segments and any `queryParams`

```js
// app.js

import router from 'router';

let result = router.recognize("/posts");
console.log('Response from call to "/posts":', result);
// Response from call to "/posts": {"0":{"handler":{"name":"posts"},"params":{},"isDynamic":false},"queryParams":{},"length":1}

result = router.recognize("/posts/1");
console.log('Response from call to "/posts/1":', result);
//Response from call to "/posts/1": {"0":{"handler":{"name":"post"},"params":{"post_id":"1"},"isDynamic":true},"queryParams":{},"length":1}

result = router.recognize("/posts?sortBy=name");
console.log('Response from call to "/posts?sortBy=name":', result);
//Response from call to "/posts?sortBy=name": {"0":{"handler":{"name":"posts"},"params":{},"isDynamic":false},"queryParams":{"sortBy":"name"},"length":1}
```

It's easy to see how this could be used now in tangent with a router of your own or the one I'm about to discuss in your app.

### [tildeio/router.js][router]

TL;DR The full example I'm going to review can be found at [hbrysiewicz/router-example][router-example].

The route-recognizer alone doesn't get you the best routing experience out of the box, unfortunately. It requires that you still manage the state of the URL and the transitions. However, the ember router itself is also available outside of the ember ecosystem. This will take us from the above example to actual routing capabilities.

[ember]: //emberjs.com
[rsvp]: //github.com/tildeio/rsvp.js
[broccoli]: //github.com/broccolijs/broccoli
[router]: //github.com/tildeio/router.js
[route-recognizer]: //github.com/tildeio/route-recognizer
[nh-route-recognizer]: //github.com/nathanhammond/ember-route-recognizer
[handlebars]: //github.com/wycats/handlebars.js
[htmlbars]: //github.com/tildeio/htmlbars
[route-recognizer-example]: //github.com/hbrysiewicz/route-recognizer-example
[router-example]: //github.com/hbrysiewicz/router-example
[sandiegojs]: //sandiegojs.org
[sdjs-talk]: https://youtu.be/wb-24NqCOT0?t=33m34s
