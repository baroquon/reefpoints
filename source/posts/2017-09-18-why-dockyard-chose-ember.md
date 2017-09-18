---
layout: post
title: "Why DockYard Chose Ember.js"
social: true
author: Michael Dupuis
twitter: "michaeldupuisjr"
github: michaeldupuisjr
summary: "And Why We Choose It Over Angular (and Angular 2) and React.js"
published: true
tags: ember.js, business development
---

DockYard builds modern web applications. This article is intended to provide an explanation as to why DockYard uses Ember.js as our frontend framework to do this.

Modern Web Apps
One characteristic of modern web apps is that they “feel” like native applications. They’re fast, fluid, and intuitive. This is made possible by Single Page Application (SPA) architecture, which loads a single HTML page and dynamically updates it via JavaScript (JS) and HTML5 APIs. You also need a backend framework that can accommodate the many requests that come with these rich UIs, which is why we use Phoenix on the backend (a topic for another article). Updating page content without requiring a page refresh was initially achieved via plain old Ajax calls, typically using jQuery.js; however, this did not provide a framework for organizing that JS code. It was a mess and typically resulted in something engineers called “jQuery soup” – an unmaintainable collage of JS code spread throughout the application.

In 2017, we have a few JavaScript frameworks that have solved this problem. Some of the most prominent are Angular 2 (Google-backed; MIT license), Ember.js (unsponsored, community-supported; MIT license), and React.js (Facebook-backed; [BSD + patent license](https://medium.com/@raulk/if-youre-a-startup-you-should-not-use-react-reflecting-on-the-bsd-patents-license-b049d4a67dd2)).

# Ember.js’s Origin Begins with Apple
As early as 2008, Apple was trying to solve the problem of building a robust, JS framework with a project known as SproutCore. A workshop in their Worldwide Developer Conference (WWDC) that year read:

> SproutCore is an open source, platform-independent, Cocoa-inspired JavaScript framework for creating web applications that look and feel like Desktop applications. Learn how to combine SproutCore with HTML5's standard offline data storage technologies to deliver a first-class user experience and exceptional performance in your web application.
> ([Apple’s open secret: SproutCore is Cocoa for the Web](http://appleinsider.com/articles/08/06/16/apples_open_secret_sproutcore_is_cocoa_for_the_web.html))

To unpack that a bit: Cocoa is the API for the Macintosh operating system (now called “macOS”); Cocoa applications are now built using Apple’s Swift programming language.

Essentially, before Apple was raking in $28B per year via the App Store, they were trying to build Progressive Web Apps. Steve Jobs’s original vision for the iPhone supports with this:

> The full Safari engine is inside of iPhone. And so, you can write amazing Web 2.0 and Ajax apps that look exactly and behave exactly like apps on the iPhone. And these apps can integrate perfectly with iPhone services. They can make a call, they can send an email, they can look up a location on Google Maps. And guess what? There’s no SDK that you need! You’ve got everything you need if you know how to write apps using the most modern web standards to write amazing apps for the iPhone today. So developers, we think we’ve got a very sweet story for you. You can begin building your iPhone apps today.
> ([Jobs’s original vision for the iPhone: No third-party native apps](https://9to5mac.com/2011/10/21/jobs-original-vision-for-the-iphone-no-third-party-native-apps/))

Fast-forwarding a bit – SproutCore 2.0 became Ember.js under the guidance of former Apple engineer Tom Dale and Ruby on Rails core team member Yehuda Katz. The project that combined Apple’s best practice application architecture with the developer-friendly ergonomics of Ruby on Rails.

# DockYard Adopts Ember.js
I joined DockYard in the spring of 2013, just as the company was ramping up on Ember.js and beginning to invest in Single Page Applications. My first day at the company was attending a small Ember.js workshop led by Dale and Katz in what is now called Boston’s “Innovation District” and is home to GE, but back then was better known as “A Bunch of Parking Lots You Don’t Want to Be In After Dark.” 

DockYard got on the Ember.js train early, before it reached `v1.0.0`, and we knew that it was the right tool for the jobs we wanted to be working on (ambitious web apps), so we never hedged our bets on Ember.js by picking up competing frameworks. We founded the Boston Ember.js Meetup group and hosted Wicked Good Ember in 2015 and 2016.

This specialist vs. generalist approach to frontend development has left a lot of React.js and Angular work on the table over the years, but it also means:

1. We’ve been building the applications we want to build for the clients we want to work with.
1. We’ve been able to develop our Ember.js expertise beyond that of other, generalist consultancies.

In short, we’ve interpreted “the right tool for the right job” to mean: find the right job.

Thankfully, Ember.js is the right tool for a lot of jobs.

# The Right Clients for Ember.js
The clients that we work with, generally have three driving concerns:

1. Is the technology choice going to be an asset or a liability to our feature roadmap?
1. Can I hire for the technology?
1. How difficult will it be to maintain and extend the application after it’s delivered?

## 1. Ember.js Enables Product Roadmaps
Ember.js’s all-in-one architecture enables teams to focus on app-specific code and defer configuration details to the framework.

### Focus on App-specific Code
Because it was inspired by Apple’s approach to native application development, Ember.js takes a holistic approach to solving the challenges that come along with modern web app development. It is comprised of libraries and APIs that standardize how developers write, test, and deploy an Ember.js application; it provides a first-class command line tool in ember-cli (which others have borrowed, sometimes with or without due attribution) and takes care of the build tooling, compression, asset fingerprinting, minification, and a host of other trivialities.

In this way, Ember.js adopts the “convention over configuration” approach that Ruby on Rails pioneered. This means that developers spend less time thinking about configuration decisions, which are often trivial for most projects, and more time thinking about the product roadmap. It also means that teams adopting Ember.js are inline with best practice web app architecture, right out of the gate. The same can’t be said for frameworks that rely on Bring Your Own layering.

Video: [Tom Dale on Ember.js Architecture vs. React.js](https://youtu.be/katGgAORrBw?t=36m14s)

### Customize as Needed
Ember.js has also worked hard to ensure that the architecture is modular. So if there are a few defaults that present challenges to specific teams, they can swap out the 10% of libraries that don’t suit them and benefit from the 90% of the framework that has been carefully curated for them. For teams that look at Ember.js’s architecture and think – we’ll probably need to rip out 50% of the defaults – Ember.js is probably the wrong framework for them.

## 2. Ember.js Hiring: Great Engineers at Critical Mass
There are more React.js developers in the world than there are Ember.js developers. Fixating on this fact is the wrong approach for building a great development team.

The better question is: are there more _good_ JavaScript developers using React.js or Ember.js?

## Leverage the Learning Curve
React.js has a smaller learning curve then Ember.js. It’s concerns are primarily “View” concerns in the “MVC” paradigm, whereas, as we detailed earlier, Ember.js is providing an all-in-one solution. This makes Ember.js more imposing to engineers, and it makes React.js look appealing to more junior-level engineers. For hiring managers, this means that, yes, it may take longer to find the right Ember.js hire, but that hire may also be a more competent, skilled engineer.

This is not to say that there aren’t brilliant React.js engineers who prefer it to Ember.js for perfectly valid reasons – there are tons of them! But it’s a counterpoint to the argument that React.js is a superior framework and that’s why there are more React.js engineers.

Going up against a Google-backed framework (Angular 2) and a Facebook-backed project (React.js) has not helped. “Nobody ever got fired for buying IBM” logic applies here, and in part, it explains why Ember.js has faced an uphill battle in the JS framework marketing war.

## Companies Using Ember.js
If you’re nervous about finding and hiring Ember.js engineers, consider the companies who have made the investment in Ember.js teams and products: Amazon, Apple, Condé Nast, Heroku (Salesforce), Kickstarter, LinkedIn, MassMutual, McGraw-Hill Education, Microsoft, Netflix, Sony, Square, TED, Yahoo, and [many more](https://emberjs.com/ember-users/).

There is already a critical mass of Ember.js developers, and the framework is growing each year alongside the [Ember Learning team](https://emberjs.com/blog/2016/02/25/announcing-embers-first-lts.html). For hiring managers who need to quickly deliver great web apps, it makes sense to adopt a framework that has some degree of a learning curve and provides a bit of engineering “natural selection.”

## 3. Ember.js for the Long-Term
Who chose Ember.js because it would be easier for our clients to maintain, extend, and upgrade.

### Onboarding New Engineers
Ember.js’s embrace of “convention over configuration” and its pursuit of an all-in-one solution pays dividends when it comes to onboarding new engineers.

Ember.js has tried-and-true best practices, which create a shared knowledgebase for the engineering team. There are fewer conversations around “what’s going on in this part of the codebase” because there is an “Ember Way” to implement much of the code. Compare that to a custom-crafted React.js tech stack which may require Senior-level engineering talent to understand, maintain, and extend responsibly.

### Invested in Web Standards
Ember.js is developed with an eye towards standards (e.g., W3C and ECMASCript TC39 (the standards body for the language)). This ensures that the framework will keep pace with the HTML and JavaScript APIs it relies on and provides a degree of future-proofing, relative to other frameworks less invested in web standards.

Video: [Tom Dale discusses Engaging with Standards at Wicked Good Ember 2016](https://youtu.be/katGgAORrBw?t=3m40s)

### Ease of Upgrading
Keeping a production application on the latest, most secure version is never easy. But it’s easier with Ember.js.

Ember.js’s all-in-one architecture means that the core libraries, while modular, are designed to fit together. The core libraries align their roadmaps and follow [Semantic Versioning](http://semver.org/) on a 6-week release cycle or about twice a year on the [Long-Term Support (LTS) release channel](https://emberjs.com/blog/2016/02/25/announcing-embers-first-lts.html). The release team also does a great job of flagging deprecated features and wrapping new ones in feature flags, to ensure that developers can test out new APIs and sunset old ones.

### Embracing Great Ideas
Ember.js is also unapologetic when it comes to stealing great ideas. When another framework does something better, Ember.js is open to adopting it. And while this requires swallowing one’s pride, the impulse to borrow from other frameworks is great for the longevity of Ember.js. For example, much of Ember.js’s advancements in the rendering and view layers are inspired by React.js’s approach to delivering fast and lightweight UI components.

Borrowing great ideas (with due attribution) will allow Ember.js to evolve with a technology space that is always fickle and ever-changing. For the last 6 years, the Ember.js community has done a great job of responsibly incorporating new ideas into the framework; their ability to continue to do so makes Ember.js a great long-term bet moving forward.
