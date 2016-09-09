---
layout: post
title: "Pieces of Ember: Part 1"
author: "Heather Brysiewicz"
twitter: "caligoanimus"
github: "hbrysiewicz"
published: true
tags: ember, javascript
summary: "How to leverage the Ember ecosystem without the Ember ecosystem"
---

I've been working with [Ember][ember] for years now, even though it feels like just yesterday. Not everyone has had this opportunity and I am often met with questions from inquisitive developers and engineers about the state of Ember.

They know that Ember is an ambitious framework. They've heard it can help boost their productivity. Yet, they hesitate. The project put in their hands is "basically just a landing page" or they believe most frameworks to be excessive - and this concern can be valid. Ember is a mature framework with opinions, build tools, and blueprints that enable me, an Ember developer, to focus on engineering an application rather than boilerplate and redundancy.

What these developers probably don't know is that many of the core pieces that make the Ember ecosystem the beautiful powerhouse that it is are also available as micro-libraries.

<br><br>
<div style="text-align:center;">
  <img src="https://i.imgur.com/PfqFoEW.png">
</div>
<br><br>

Some of the most well known micro-libraries behind the Ember framework are:

* [tildeio/rsvp.js][rsvp]
* [broccolijs/broccoli][broccoli]
* [tildeio/route-recognizer][route-recognizer]
* [tildeio/router.js][router]
* [wycats/handlebars.js][handlebars]
* [tildeio/htmlbars][htmlbars]

These pieces of Ember would be able to provide any JavaScript project with:

* Promises
* Build tools
* Routing capabilities
* View templating
* Templating with Virtual DOM

All without the need to buy into the entire Ember ecosystem.

This post is part 1 of a 3 part series on the pieces of Ember. It is also a continuation or elaboration of a lightning talk I gave at the July [SanDiego.js Community][sandiegojs] event which can be found [here][sdjs-talk].

* [Part 1: RSVP and Broccoli][part1]
* Part 2: Route-recognizer and Router
* Part 3: Handlebars and HTMLBars

### [tildeio/rsvp.js][rsvp]

This library is a tiny implementation of the [Promises/A+ spec][promises]. This can be used without a transpiler just like any other promise library.

The library itself is rather similar to [Bluebird][bluebird] and [When][when]. Under the hood there are some performance boosts gained by avoiding unnecessary internal promise allocations. This provides noticeable improvements in many common scenarios.

The other unique thing to note about this library is that RSVP aims to be fast across more than just the V8 runtime, while libraries like Bluebird are more or less V8-focused.

```js
let RSVP = require('rsvp');

let promise = new RSVP.Promise((resolve, reject) => {
  //succeed
  resolve(value);
  // or reject
  reject(error)
});

promise.then((value) => {
  //success
}).catch((error) => {
  // failure
});

```

### [broccolijs/broccoli][broccoli]

Broccoli is the fast build pipeline used by [ember-cli][ember-cli] and that is available outside of the Ember ecosystem. Broccoli is intended to be relatively easy to learn, performant, and composable. The plugin system for broccoli is what makes it so composable and even with plugins depending on other plugins, creating a large tree of plugin dependencies, broccoli manages to still provide performant sub-second speeds.

Broccoli provides a powerful build tool chain that can be used very easily to get a project up and running outside of Ember.

Given a simple project with the following structure:

```
.
+-- app
|   +-- css
|   +-- js
|   +-- img
|   +-- index.html
+-- node_modules/
+-- .gitignore
+-- Brocfile.js
+-- README.md
+-- package.json
```

It is easy to serve up the assets and create a pipeline with just a few key broccoli plugins and a rather short `Brocfile.js`.

```bash
$ npm i --save-dev broccoli-concat
$ npm i --save-dev broccoli-merge-trees
$ npm i --save-dev broccoli-static-compiler
$ npm i --save-dev broccoli-uglify-js
```

```js
'use strict';

const concatenate = require('broccoli-concat');
const mergeTrees = require('broccoli-merge-trees');
const pickFiles = require('broccoli-static-compiler');
const uglifyJS = require('broccoli-uglify-js');

const app = 'app';

let appCSS;
let appHTML;
let appJS;
let appImages;

/*
 * move index from `app/` to root of tree
 */
appHTML = pickFiles(app, {
    srcDir: '/',
    files: ['index.html'],
    destDir: '/'
});

/*
 * concat and compress all js files from `app/js/` and move to root
 */
appJS = concatenate(app, {
  inputFiles: ['js/**/*.js'],
  outputFile: '/app.js'
});

appJS = uglifyJS(appJS, {
  compress: true
});

/*
 * concat all css files from `app/css/` and move to root
 */
appCSS = concatenate(app, {
  inputFiles: ['css/**/*.css'],
  outputFile: '/app.css'
});

/*
 * move images from `app/img` to image folder
 */
appImages = pickFiles(app, {
  srcDir: '/img',
  files: ['**/*'],
  destDir: '/img'
});

// merge the trees and export
module.exports = mergeTrees([appHTML, appJS, appCSS, appImages]);

```

Now running `broccoli serve` will build and serve the project and provide build times in a well formated and easy to read table.

```
Serving on http://localhost:4200


Slowest Trees                                 | Total
----------------------------------------------+---------------------
SourceMapConcat                               | 30ms
UglifyJSFilter                                | 13ms
BroccoliMergeTrees                            | 7ms
StaticCompiler                                | 3ms
Slowest Trees (cumulative)                    | Total (avg)
----------------------------------------------+---------------------
SourceMapConcat (1)                           | 30ms
UglifyJSFilter (1)                            | 13ms
BroccoliMergeTrees (1)                        | 7ms
StaticCompiler (2)                            | 6ms (3 ms)

Built - 63 ms @ Tue Jul 26 2016 16:43:40 GMT-0700 (PDT)
```

When ready to build for deployment the command `broccoli build 'dist'` would compile all of the assets into the `dist` directory.

### Get more from the Ember ecosystem

Check back for part 2 and part 3 of this series where I review the routing capabilities and templating systems and how to use them outside of Ember.

[ember]: //emberjs.com
[ember-cli]: https://ember-cli.com
[stefanpenner]: https://github.com/stefanpenner
[rsvp]: //github.com/tildeio/rsvp.js
[bluebird]: http://bluebirdjs.com/
[when]: https://github.com/cujojs/when
[broccoli]: //github.com/broccolijs/broccoli
[broccoli-release]: https://www.solitr.com/blog/2014/02/broccoli-first-release/
[brocolli-deps]: https://libraries.io/npm/broccoli/dependents?page=1
[router]: //github.com/tildeio/router.js
[route-recognizer]: //github.com/tildeio/route-recognizer
[handlebars]: //github.com/wycats/handlebars.js
[htmlbars]: //github.com/tildeio/htmlbars
[promises]: https://promisesaplus.com/
[sandiegojs]: //sandiegojs.org
[sdjs-talk]: https://youtu.be/wb-24NqCOT0?t=33m34s
[part1]: //dockyard.com/blog/2016/08/12/pieces-of-ember-part1
