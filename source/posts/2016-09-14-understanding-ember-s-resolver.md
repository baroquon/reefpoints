---
layout: post
title: "Understanding Ember's resolver"
social: true
author: Marten Schilstra
twitter: "martndemus"
github: martndemus
summary: "An introduction to how Ember's resolver works"
published: true
tags: ember, javascript, engineering
---

Ember's [dependency injection](https://guides.emberjs.com/v2.8.0/applications/dependency-injection/) system is driven by a resolver.
It is used to lookup JavaScript modules agnostic from what kind of module system is used, which can be AMD, CommonJS or just plain globals.
A resolver works based on a set of rules, which reflects how Ember apps are structured.

## How the resolver is used

The resolver is used widely throughout an Ember application.
It is used to lookup routes, models, components and much more.

When your Ember app transitions into a route, the resolver is used to find the corresponding route module. 
For example: if you navigate to `/blog`, then the blog route needs to be looked up. 
This is done by asking the resolver to resolve `route:blog`, this will resolve a module named `blog` of type `route`.
After the route is done loading the model, we need a controller, so we ask the resolver for `controller:blog`. 
Lastly a template needs to be rendered, so once again we go to the resolver and ask for `template:blog`.

The same thing happens when rendering a component. First the resolver is asked for `component:my-component`,
then `template:component/my-component`.

## The rules of the resolver

Today the resolver is used the most to resolve modules using Ember CLI's AMD module system.
So I'm going to use that in the next few examples.

### The prefix

First of all, a resolver requires a `modulePrefix` variable.
This variable is found in the `config/environment` file of an Ember CLI app and is being passed to the resolver by your Ember application.
You should also know that the `app/routes/blog.js` file in your Ember CLI app gets a different path in the compiled output.
The `app` part of the path is replaced by the `modulePrefix` variable. So our example would become `my-app/routes/blog` if our `modulePrefix` variable is `my-app`.

### Dissecting a resolver statement

The resolver disects the statement `route:blog` into two parts, a type (`route`) and a name (`blog`). Those parts are then translated into a path which can be used to load a module.
In the case of Ember CLI's AMD modules it would give you `my-app/routes/blog`, which is constructed of `modulePrefix` / `type` (pluralized) / `name`.

The resolver can also easily resolve things nested inside subfolders.
For example, `template:component/my-component`, it'll be resolved to `my-app/templates/components/my-component`.

You can also make up your own type, it doesn't have to be one of Ember's types.
For example, [Ember Validations](https://github.com/DockYard/ember-validations) uses the resolver to look up modules of the `validator` type.

### Resolving addon modules 

The resolver has one more trick up its sleeve, it can resolve things outside of your app using a custom `modulePrefix`.
If you prefix the statement asked to the resolver with your custom `modulePrefix` and an `@`, then it'll replace the configured `modulePrefix` with yours.
The statement `an-addon@component:x-utility` would be resolved to `an-addon/components/x-utility`.

### Some exceptions

The resolver has some exceptions built in, to resolve a few special things. 
Anything with `main` as the name part will resolve without the name in the resulting module name.
So `router:main` will resolve to `my-app/router`, leaving out the name part. The same rule applies to `store:main`.

### Conclusion

The resolver is a fairly straightforward abstraction that helps you resolve modules, agnostic from all the various module loading systems.
If you get to know how it works it can be a great new tool in your arsenal.
