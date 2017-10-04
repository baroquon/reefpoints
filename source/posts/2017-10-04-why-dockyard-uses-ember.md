---
layout: post
title: "Why DockYard Builds with Ember.js"
social: true
author: Michael Dupuis
twitter: "michaeldupuisjr"
github: michaeldupuisjr
summary: "And how it meets the top 3 needs of our clients better than competing web frameworks."
published: true
tags: ember, business development
---

![Wicked Good Ember t-shirts](https://i.imgur.com/RJb2fks.jpg)

DockYard builds modern web applications for all platforms. This article is intended to provide an explanation as to why DockYard uses Ember.js as our frontend framework to do this.

## Modern Web Apps
One characteristic of modern web apps is that they “feel” like traditional mobile and desktop applications. They’re fast, fluid, and intuitive. This is made possible by [Single Page Application (SPA)](https://dockyard.com/blog/2016/06/13/how-technology-choices-affect-user-experience) architecture, which loads a single HTML page and dynamically updates it via JavaScript (JS) and HTML5 APIs. You also need a backend framework that can accommodate the many requests that come with these rich UIs, which is why we use [Elixir and Phoenix](https://dockyard.com/phoenix-consulting) on the backend (a topic for another article). Updating page content without requiring a page refresh was initially achieved via plain old Ajax calls, typically using jQuery; however, this did not provide a framework for organizing that JS code. It was a mess and typically resulted in something developers called “jQuery soup” – an unmaintainable collage of JS code spread throughout the application.

In 2017, two of the predominant JavaScript frameworks for building Single Page Applications are Angular 2 and Ember.js. People often include React.js, as well; however, React.js is a library for building user interfaces, rather than a framework (it can be bundled with other libraries for teams interested in building and maintaining their own web framework).

## Ember.js’s Origin Begins with Apple
As early as 2008, Apple was trying to solve the problem of building a robust, JS framework with a project known as SproutCore. A workshop at their Worldwide Developer Conference (WWDC) that year read:

> SproutCore is an open source, platform-independent, Cocoa-inspired JavaScript framework for creating web applications that look and feel like Desktop applications. Learn how to combine SproutCore with HTML5's standard offline data storage technologies to deliver a first-class user experience and exceptional performance in your web application.
> ([Apple’s open secret: SproutCore is Cocoa for the Web](http://appleinsider.com/articles/08/06/16/apples_open_secret_sproutcore_is_cocoa_for_the_web.html))

To unpack that a bit: Cocoa is the API for the Macintosh operating system (now called “macOS”); Cocoa applications are now built using Apple’s Swift programming language.

Essentially, before Apple was raking in $28B per year via the App Store, they were trying to build Progressive Web Apps. Steve Jobs’s original vision for the iPhone supports this with:

> The full Safari engine is inside of iPhone. And so, you can write amazing Web 2.0 and Ajax apps that look exactly and behave exactly like apps on the iPhone. And these apps can integrate perfectly with iPhone services. They can make a call, they can send an email, they can look up a location on Google Maps. And guess what? There’s no SDK that you need! You’ve got everything you need if you know how to write apps using the most modern web standards to write amazing apps for the iPhone today. So developers, we think we’ve got a very sweet story for you. You can begin building your iPhone apps today.
> ([Jobs’s original vision for the iPhone: No third-party native apps](https://9to5mac.com/2011/10/21/jobs-original-vision-for-the-iphone-no-third-party-native-apps/))

Fast-forwarding a bit – SproutCore 2.0 became Ember.js under the guidance of former Apple developer Tom Dale and Ruby on Rails core team member Yehuda Katz. The project combined Apple’s best practice application architecture with the developer-friendly ergonomics of Ruby on Rails.

## DockYard Adopts Ember.js
DockYard got on the Ember.js train early, before it reached `v1.0.0`. We knew that it was the right tool for the jobs we wanted to be working on (ambitious web apps), so we never hedged our bets on Ember.js by picking up competing frameworks. We've organized the [Boston Ember.js Group](https://www.meetup.com/Boston-Ember-js/) since 2013 and hosted Wicked Good Ember in [2014](https://wickedgoodember.com/2014), [2015](https://wickedgoodember.com/2015), and [2016](https://wickedgoodember.com/).

![Wicked Good Ember 2016](https://i.imgur.com/ByETXDs.jpg)

We've been the top sponsor for EmberConf (2015) and have sponsored the work of [Igor Terzic](https://github.com/igorT) on [Ember Data](https://github.com/emberjs/data).

This specialist vs. generalist approach to frontend development has left a lot of React.js, Angular 1, and Angular 2 work on the table over the years, but it has also meant:

1. We’ve been building the applications we want to build for the clients we want to work with.
1. We’ve been able to develop our Ember.js expertise beyond that of other, generalist consultancies.
1. It has attracted the best talent to DockYard.

In short, we’ve interpreted “the right tool for the right job” to mean: find the right job.

Thankfully, Ember.js is the right tool for a lot of projects.

## The Right Clients for Ember.js
The clients that we work with generally have three driving concerns:

1. Is the technology choice going to be an asset or a liability to our feature roadmap?
1. Can I hire for the technology?
1. How difficult will it be to maintain and extend the application after it’s delivered?

### 1. Ember.js Enables Product Roadmaps
Ember.js’s all-in-one architecture enables teams to focus on app-specific code and defer configuration details to the framework. This is better known as ["convention over configuration."](https://en.wikipedia.org/wiki/Convention_over_configuration)

#### Focus on App-specific Code
Because it was inspired by Apple’s approach to native application development, Ember.js takes a holistic approach to solving the challenges that come along with modern web app development. It is comprised of libraries and APIs that standardize how developers write, test, and deploy an Ember.js application; it provides a first-class command line tool in ember-cli (which others have "borrowed") and takes care of the build tooling, compression, asset fingerprinting, minification, and a host of other trivialities.

Again, Ember.js adopts the “convention over configuration” approach that Ruby on Rails pioneered. This means that developers spend less time thinking about configuration decisions, and more time thinking about the product roadmap. It also means that teams adopting Ember.js are inline with best practice web app architecture right out of the gate. The same can’t be said for frameworks that rely on Bring Your Own layering.

Video: [Tom Dale on Ember.js Architecture vs. React.js](https://youtu.be/katGgAORrBw?t=36m14s)

#### Customize as Needed
Ember.js has also worked hard to ensure that the architecture is modular. So if there are a few defaults that present challenges to specific teams, they can swap out the 10% of libraries that don’t suit them and benefit from the 90% of the framework that has been carefully curated for them. For teams that look at Ember.js’s architecture and think – we’ll probably need to rip out 50% of the defaults – Ember.js is probably the wrong framework for them.

### 2. Ember.js Hiring: Great Developers at Critical Mass
"There are more [insert hot, new JS library here] developers in the world than there are Ember.js developers."

Going up against a Google-backed framework (Angular 2) and a Facebook-backed project (React.js) has not helped Ember.js win adoption. “Nobody ever got fired for buying IBM” logic applies here, and in part, it explains why Ember.js has faced an uphill battle in the JS framework marketing war.

But fixating on this fact is the wrong approach for building a great development team. The better question is: how many more _good_ [hot, new JS].js developers are
there than _good_ Ember.js developers?

### Leverage the Learning Curve
A competing frameworks homepage reads:
_"Already know HTML, CSS, and JavaScript? Read the guide and start building things in no time!"_

Compare this to Ember.js's homepage, which reads:
_"A framework for creating ambitious web applications."_

Ember.js provides a solution that goes beyond the narrow concerns of other libraries, and this naturally comes with more to learn. But part of what makes Ember.js difficult to adopt is what makes its developers so great: it's more imposing to junior-level developers and provides some natural selection in the hiring process.

For hiring purposes, it can be useful to ask:
1. Does the technology have critical mass?
1. Does the technology make it more or less likely we build a great
   team?

There is already a critical mass of Ember.js developers, and the framework is growing each year alongside the [Ember Learning team](https://www.emberjs.com/blog/2016/05/19/introducing-subteams.html#toc_learning). For hiring managers who need to quickly deliver great web apps, it makes sense to adopt a framework that focuses less on short-term adoption and more on long-term potential.

### Companies Using Ember.js
If you’re nervous about finding and hiring Ember.js developers, consider the companies who have made the investment in Ember.js: Amazon, Apple, Condé Nast, Heroku (Salesforce), Kickstarter, LinkedIn, MassMutual, McGraw-Hill Education, Microsoft, Netflix, Sony, Square, TED, Yahoo, and [many more](https://emberjs.com/ember-users/).

### 3. Ember.js for the Long-Term
We chose Ember.js because it would be easier for our clients to maintain, extend, and upgrade.

#### Onboarding New Developers
Ember.js’s embrace of “convention over configuration” and its pursuit of an all-in-one solution pays dividends when it comes to onboarding new developers.

Ember.js has tried-and-true best practices, which create a shared knowledge base for the development team. There are fewer conversations around “what’s going on in this part of the codebase” because there is an “Ember Way” to implement much of the code. Compare that to a custom-crafted, frontend tech stack which may require Senior-level developer talent to understand, maintain, and extend responsibly.

#### Invested in Web Standards
Ember.js is developed with an eye towards standards such as W3C and ECMAScript TC39 (the standards body for the language). This ensures that the framework will keep pace with the HTML and JavaScript APIs it relies on and provides a degree of future-proofing, relative to other frameworks less invested in web standards.

Video: [Tom Dale discusses Engaging with Standards at Wicked Good Ember 2016](https://youtu.be/katGgAORrBw?t=3m40s)

#### Ease of Upgrading
Keeping a production application on the latest, most secure version is never easy. But it’s easier with Ember.js.

Ember.js’s all-in-one architecture means that the core libraries, while modular, are designed to fit together. The core libraries align their roadmaps and follow [Semantic Versioning](http://semver.org/) on a 6-week release cycle or about twice a year on the [Long-Term Support (LTS) release channel](https://emberjs.com/blog/2016/02/25/announcing-embers-first-lts.html). The release team also does a great job of flagging deprecated features and wrapping new ones in feature flags, to ensure that developers can test out new APIs and sunset old ones.

#### Embracing Great Ideas
Ember.js is also unapologetic when it comes to borrowing great ideas. When another framework does something better, Ember.js is open to adopting it. And while this requires swallowing one’s pride, the impulse to borrow from other frameworks is great for the longevity of Ember.js. For example, much of Ember.js’s advancements in the rendering and view layers are inspired by React.js’s approach to delivering fast and lightweight UI components.

Borrowing great ideas (with due attribution) will allow Ember.js to evolve with a technology space that is always fickle and ever-changing. For the last 6 years, the Ember.js community has done a great job of responsibly incorporating new ideas into the framework; their ability to continue to do so makes Ember.js a great long-term bet moving forward.
