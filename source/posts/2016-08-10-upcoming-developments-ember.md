---
layout: post
title: "ELI5: Upcoming Developments in Ember.js"
social: true
author: Rowan Krishnan
github: rkrishnan8594
summary: "A brief tour of Ember's future through a few RFCs."
published: true
tags: ember.js
---

# ELI5: Upcoming Developments in Ember.js

As a newcomer to [Ember](http://emberjs.com/) in the past few months, it's been fascinating to not only learn how to build applications with a great JS framework, but also to gain insight into how a massive and popular open source project grows and absorbs new ideas. Although I'm probably a little bit biased at this point, I believe Ember does a better job than most at managing and encouraging this process.

The primary channel for discussion of introducing new features into Ember is the [public RFC repository](https://github.com/emberjs/rfcs) on GitHub. RFCs, which stand for 'Request For Comment', are pull requests in which any developer can outline a feature specification and open the floor for comments and criticism. This is what true open source looks like, and the success of the RFC repo represents to me the best aspects of the Ember community. 

All of that being said, it can certainly be a little intimidating for someone new to the framework to dive right in and catch up on the most significant RFCs being discussed. So I decided to do a little write up that made that easier.

Here are the three RFCs that have provoked the most discussion, and perhaps demonstrate what the future of Ember looks like:

## [Module Unification](https://github.com/emberjs/rfcs/pull/143)

`Create a unified pattern for organizing and naming modules in Ember projects that is deterministic, extensible, and ergonomic.`

This seems like the best one to start with, since it's the one most likely to affect all users of Ember and dramatically impact daily use of the framework. In short, this RFC aims to provide an improved ergonomic directory structure for all new Ember projects.

Why? Well, there are unfortunately a few too many deficiencies with the current system of organizing Ember modules.

- Developers have to decide between using the pod or classic app structure.
- Addons are directly mixed into the codebase and therefore present opportunities for name collision.
- Module resolution rules are esoteric and inefficient.

The proposed solution to these problems does a major refactor of default Ember app structure. Replacing `app` at the top level is a new directory called `src` which can contain several subdirectories (`data`, `init`, `ui`, `utils`, and `services`). Here's an example of what this could look like in a blogging application, as shown in the RFC:

```
src
  data
    models
      author.js
      comment
        adapter.js
        model.js
        serializer.js
      post
        adapter.js
        model.js
        serializer.js
    transforms
      date.js
  init
    initializers
      i18n.js
    instance-initializers
      auth.js
  services
    auth.js
  ui
    components
      capitalize.js
      date-picker
        component.js
        template.hbs
      list-paginator
        component.js
        template.hbs
        paginator-control
          component.js
          template.hbs
    partials
      footer.hbs
    routes
      application
        template.hbs
      index
        template.hbs
        route.js
        controller.js
      posts
        -components
          capitalize.js
          titleize.js
          -utils
            strings.js
        post
          -components
            post-viewer
              component.js
              template.hbs
          edit
            -components
              post-editor
                post-editor-button
                  component.js
                  template.hbs
                calculate-post-title.js
                component.js
                template.hbs
            route.js
            template.hbs
          route.js
          template.hbs
        route.js
        template.hbs
    styles
      app.scss
    index.html
  utils
    md5.js
  main.js
  router.js
```

There are a couple of examples of this in action; namely the [Ghost Admin](https://github.com/rwjblue/--ghost-modules-sample/tree/grouped-collections/src) and [Travis Client](https://github.com/rwjblue/--travis-modules-sample/tree/modules/src). [Rob Jackson](https://twitter.com/rwjblue) has also done a fantastic job in releasing a [tool](https://github.com/rwjblue/ember-module-migrator) that allows us to migrate our apps over to this new structure.

The RFC goes into a great amount of detail regarding other changes that will need to take place, such as renaming and reorganizing modules, and a refactor of the Ember Resolver. You can read the whole thing [here](https://github.com/dgeb/rfcs/blob/module-unification/text/0000-module-unification.md).

## [Testing Unification](https://github.com/emberjs/rfcs/pull/119)

`The goal of this RFC is to unify the concepts amongst the various types of test (acceptance, integration, and unit) and provide a single common structure to tests.`

Look, most of us don't really love writing tests. It's okay to admit it. But as [Rob Jackson](https://github.com/rwjblue) explains in his RFC, Ember's testing story is coming together quite nicely, and it's never been easier to write comprehensive tests across all the various pieces of your app (routes, components, templates, etc). One of the best aspects of Ember being a "full featured" framework is that it comes packaged with all the libraries and tools you'd need to write great tests, with as little friction as possible.

The only persisting problem is that these tests look and function quite different from one another. Specifically, they handle things like asynchronous requests differently and use unique sets of helpers. This RFC seeks to "unify" the three types of tests - acceptance, integration, and unit - by introducing new syntax to handle asynchronous test actions, and establishing a set of test helpers that would be shared across the three types of tests.

Like the [Module Unification RFC](https://github.com/emberjs/rfcs/pull/143), this one goes into a great amount of detail that eclipses the scope of an ELI5. I highly recommend checking it out the [full spec](https://github.com/rwjblue/rfcs/blob/42/text/0000-grand-testing-unification.md) if you're interested in the future of testing.

## [Routable Components](https://github.com/emberjs/rfcs/pull/38)

`Eliminates Controllers.`

Ah, yes. The Holy Grail of RFCs. The future of Ember. The promised land.

In all seriousness, routable components are a pretty big deal, and received an appropriately large reaction when first presented at EmberConf 2015 by [Tom Dale](https://github.com/tomdale) & [Yehuda Katz](https://github.com/wycats). It's been a long time since then, and if you've been following along, you might need a little refresher on how they are intended to work.

As the description above concisely states, routable components essentially mean the death and deprecation of controllers. This is a good thing. For many months now, controllers have been a key point of confusion for new developers, and stick out as a remnant of pre-2.0 Ember. One of the biggest complaints about the framework in the early years was that the architectural pattern was far too complicated ("MVC? MVVM? What's the difference between a view and a controller?"). Ember continuing to simplify and mature these patterns is great news.

Routable components hope to replace controllers by absorbing the few functional responsibilities that they still have, such as query parameters and setting a route's model on the template or top-level component. Discussing the implementation for these changes, however, is a tricky subject due to the length of time passed since the concept of routable components was first introduced. Original proposals included removing older model hooks (such as `beforeModel` and `afterModel`) and introducing a new, automatically invoked hook called "attributes", that would allow a route to specify the positional and query parameters to be passed into a rendered component.






