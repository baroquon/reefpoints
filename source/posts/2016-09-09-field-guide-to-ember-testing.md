---
layout: post
title: "A field guide to Ember.JS testing"
social: true
author: Marten Schilstra
twitter: "martndemus"
github: martndemus
summary: ""
published: true
tags: tags, separating each, with commas
---

I am a big fan of the Test Driven Development school. Every piece of logic you add to your application should be backed by at least one test. Every change in logic should see an update to a test.

Practicing Test Driven Development with Ember can be tricky. Certainly when you're not very familiar with how Ember's set of testing tools works. That can be frustrating and may lead to the inability to test a certain piece of your app. Not being able to test the code you write is very bad, as it will lead to [broken windows](https://en.wikipedia.org/wiki/Broken_windows_theory) in your app.

I've written the following post to help guide you to become proficient enough to be able to always write tests in mosts of the situations that may arise when developing an Ember app.

### A well placed test

Before writing tests it's good to know where a test goes. Should your test be an acceptance, integration or unit test? That of course depends on what kind of Ember thing you're working on.

Most tests go into the integration part of the test suite. Component tests, for example, go into this category and will make up the bulk of your integration tests and likely even the whole test suite. Not only component tests are best tested as integration tests, helpers are best tested with an integration test too.

Use acceptance test to test the data loading and route transitioning part of the app, doing this will mostly be enough to test the correctness of the route's template.

Everything else should be tested with just unit tests. If the unit under test becomes hard to test because it depends on Ember's dependency injection system, then it's best to promote the test to an integration test, I'll discuss later how this is done.

### Test module basics

What kind of test a test is, is not decided by in which folder it is put in, but by which kind of test module is used. `moduleForAcceptance`, as the name implies, sets up an acceptance test; `moduleFor` sets up either an integration or unit test. There are also a few test modules specifically for one kind of Ember concept, namely `moduleForComponent` to test components and `moduleForModel` to test models.

#### moduleFor as unit test

This module will be the meat and potatoes of your unit testing. It's pretty much a slightly enhanced version of QUnit's `module`. The biggest distinction is that in this case you state what kind of module it's for. An example:

```js
moduleFor('model:user', 'Unit | Model | User');
```

This declares a test module that has the `User` model as subject and that it should be resolved through Ember's DI system as `'model:user'`. In subsequent tests you can use the `subject` method from the `this` context to construct a `User` model.

If the user depends on another model, for example a `Profile`, then it might be possible that you will face an error that states that it can not find the `Profile` model. To fix this, you need to declare in the module that this module also needs the `Profile` model, using the `needs` option.

```js
moduleFor('model:user', 'Unit | Model | User', {
  needs: ['model:profile']
});
```

#### moduleFor as integration test

Switching from a unit to an intregration test is very simple, all you have to do is to remove the `needs` property (if present) and add the `integration` property. The switch means that you don't have to manually specify all your dependencies in the `needs` hook anymore. In integration mode, all dependencies will be resolved automatically. This is the only distinction between the two modes.

```js
moduleFor('model:user', 'Integration | Model | User', {
  integration: true
});
```

With this setup, adding dependencies to the `needs` array is a thing of the past.

#### moduleForModel

The `moduleForModel` module is a slightly enhanced version of the regular `moduleFor` module. It sets up Ember Data's store on the test context and it alters the `this.subject` function to create a model into that store (I'll talk about `this.subject` more in detail later). Another slight change is you can just put the model's name into the first argument of the module function.

```js
moduleForModel('user', 'Unit | Model | User');
```

#### moduleForComponent

The `moduleForComponent` module adds the ability to render arbitrary templates and being able to interact with them to your tests in integration mode. The module also has a unit test mode, but I recommend not using it, components are best tested with integration tests.

```js
moduleForComponent('my-component', 'Integration | Component | {{my-component}}', {
  integration: true
});
```

#### moduleForAcceptance

The `moduleForAcceptance` module is just a plain QUnit module, except that it takes care of starting and destroying your Ember app for each test.
