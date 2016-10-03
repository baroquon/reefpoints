---
layout: post
title: "Retiring Ember Suave"
social: true
author: Estelle DeBlois
twitter: "edeblois"
github: brzpegasus
summary: "Following the merge of JSCS with ESLint, `ember-suave` now has a new successor."
published: true
tags: engineering, ember, javascript
---

_"The role of style in programming is the same as in literature: It makes for better reading. A great writer doesn't express herself by putting the spaces before her commas instead of after, or by putting extra spaces inside her parentheses. A great writer will slavishly conform to some rules of style, and that in no way constrains her power to express herself creatively."_

While the writer analogy taken from Douglas Crockford's much rigid [JSLint](https://github.com/douglascrockford/JSLint) may hold true for the English language, even something as simple as a space can follow different rules in different parts of the world. For instance, in French, the exclamation point is always preceded by a space.

In the world of code, it matters less whether you are a fan of semi-colons first, or whether you favor [tabs over spaces](https://www.youtube.com/watch?v=SsoOG6ZeyUI) (except that we all know one is right and the other is wrong); what matters is that code style is consistent within a team, and that there is a way to enforce it.

## The rise of `ember-suave`

When my fellow DockYarders and I originally decided to make code style checking a part of our regular Ember CLI development workflow, [JSCS](http://jscs.info/) was the de facto code style checker. We thus set out to build [`ember-suave`](https://github.com/DockYard/ember-suave).

The addon used [`broccoli-jscs`](https://github.com/kellyselden/broccoli-jscs) internally, but it also shipped with an already configured set of JSCS rules as well as custom rules we had written. We wanted it to be opinionated, something that we could simply drop into any of our Ember CLI projects and start coding against. We wanted to put the S in Suave.

We also made the preset configurable with the hope that it would be usable by anyone outside of DockYard who might be looking for a quick jump start on JSCS, since they would only need to overwrite those rules that do not align with their team's style guide. It turns out that `ember-suave` did end up being used across a sizeable number of [projects](https://github.com/search?l=&p=3&q=ember-suave+extension%3Ajson&ref=advsearch&type=Code&utf8=%E2%9C%93).

For all those folks, I would like to announce at last that we are retiring `ember-suave`. This means that we will no longer build custom rules for it or enhance it in any way, and that it may just as well find its way into [Davy Jones' Locker](https://github.com/DavyJonesLocker), which is where all abandoned DockYard open-source projects go to die.

## JSHint, JSCS, and ESLint

JSCS reached [end-of-life](http://eslint.org/blog/2016/07/jscs-end-of-life) back in July, three months after joining up with [ESLint](http://eslint.org/).

For a bit of history, when [JSHint](http://jshint.com/about/) started focusing strictly on functional rules, JSCS emerged as the static analysis tool for all stylistic concerns in JavaScript. This was sometime back in 2013. For the longest time, JSHint and JSCS complemented each other rather well.

Meanwhile, Nicholas Zakas [created](https://www.nczonline.net/blog/2013/07/16/introducing-eslint/) ESLint as a fully pluggable alternative to JSHint. As ESLint and JSCS matured and grew in popularity, the two projects started overlapping in functionality and goals, so instead of continuing to lead separate ways, they joined up. You can read more about the merge [here](http://eslint.org/blog/2016/04/welcoming-jscs-to-eslint).

## `ember-suave` returns as an ESLint plugin

Most of the rules from `ember-suave`, including the custom ones, have been converted to ESLint in a new repo called [`eslint-plugin-ember-suave`](https://github.com/DockYard/eslint-plugin-ember-suave).

The biggest difference is that you are no longer looking at an Ember CLI addon. `eslint-plugin-ember-suave`, as its name implies, is simply an ESLint plugin (the equivalent of a JSCS preset). It's just a collection of custom rules and their configuration, as well as configuration of additional rules already built into ESLint.

In order to run ESLint with the supplied configuration, you will need to install the [`ember-cli-eslint`](https://github.com/ember-cli/ember-cli-eslint) addon into your Ember project. It is worth noting that doing so will also uninstall any existing installation of [`ember-cli-jshint`](https://github.com/ember-cli/ember-cli-jshint), since it doesn't make sense to use both linters simultaneously.

## The joy of having contributors

Migrating `ember-suave` over to an ESLint plugin had been a lingering goal for quite some time. I just happened to have limited time to devote to it. To that end, I have contributors to thank, particularly [Alex LaFroscia](https://github.com/alexlafroscia), for spearheading the effort. He rewrote all the JSCS custom rules we had in `ember-suave` to their ESLint equivalents. [Robert Wagner](https://github.com/rwwagner90) also landed a hand in accelerating the development of the plugin, at a time when I was mostly taking a hands-off stance due to maternity leave. I do appreciate that they motivated me to code every now and then, as much as it was challenging to pair program with a two-month old.
