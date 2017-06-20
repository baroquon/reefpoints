---
layout: post
title: "Safari, iOS, and Progressive Web Apps: what you should know"
social: true
author: Jess Krywosa
twitter: "jesskry"
github:
summary: "Interested in a Progressive Web App but unsure about implementing one without Safari/iOS support? Here’s what you should know before making a decision."
published: true
tags: PWA, Business
---
 
Progressive Web Apps (PWAs) are gaining in popularity due to their ability to send push notifications, add to home screen prompts, and provide offline content, with one build for all devices. Since PWAs focus on the browser and are device agnostic, they allow for seamless adoption by all users, while cutting costs and maintenance for businesses. Outcomes for implementors like MakeMyTrip.com include [triple the conversion rates, 38% improvement in page load times, and 160% increase in sessions](https://developers.google.com/web/showcase/2017/make-my-trip). 
 
A lot of the functionality that PWAs provide is due to the addition of services workers. Currently, Chrome, Opera, Firefox, Samsung internet, and Edge [all support or plan to support, service workers](https://jakearchibald.github.io/isserviceworkerready/). But many still feel unsure about adopting PWAs due to the lack of full-throated support for service workers—and PWAs–from Apple. 
 
Interested in transitioning to a Progressive Web App but unsure about implementing one without Safari/iOS support? Here’s what you should know before making a decision. 
 
## What about PWAs doesn’t Safari/iOS readily support?
 
As of today, Safari/iOS do not support service worker and web app manifest. Without these, many forward thinking components of PWAs will not work as intended including push notifications, home screen installation, and offline mode. 
 
## Are there any browsers that support PWAs on Apple devices? 
 
Sadly, No. Browsers like Chrome that do readily support all aspects of PWAs are really only [re-skinned versions of Safari](https://www.digitalcommerce360.com/2017/05/02/apples-dirty-little-secret-about-chrome/) on iOS devices.
 
## So, if my primary mobile audience is Apple users, why would I implement a PWA?
 
Even without this support, PWAs still work, just not as they were originally envisioned and require workarounds. You can still implement an add to homescreen prompt, you’ll just have to do so by using ember-web-app if using Ember. While you can implement OS X push notifications from your web site using [Apple’s developer guides](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/NotificationProgrammingGuideForWebsites/Introduction/Introduction.html) this does not solve the issue for iOS. One inelegant solution is to wrap the PWA in a native app to gain initial approval for notifications. Offline content is a harder issue to solve, though the other enhancements can be combatted while we anxiously await iOS support. 
 
[Documented early adopter outcomes](https://developers.google.com/web/showcase/2017/) actually show that not only do PWAs work across all browsers, but they actually convert higher than non-PWA sites. Since Progressive Web Apps were built to be lighter they automatically perform better via mobile even without the added enhancements. Lancome recently opted to upgrade to a PWA instead of developing a native app to be able to both serve current customers and reach new users. Even without iOS support [they still saw iOS sessions increase by 53% and overall conversions increase by 17%](https://developers.google.com/web/showcase/2017/lancome). 
 
## Will Apple adopt?
 
Indications look positive. Webkit shows that both [service workers](https://webkit.org/status/#specification-service-workers) and [web app manifests](https://webkit.org/status/#specification-web-app-manifest) are ‘under consideration’, with the former given specific mention in the [five year plan](https://webkit.org/status/#specification-web-app-manifest). Speculation is that Apple could be slow to adopt due to their current reliance on apps and the App Store. Why promote technology that may eat into that owned pipeline? With Samsung, Google, and Microsoft currently running with this functionality, Apple may be hedging their bets. And with PWAs meaning an easier, single point of contact with consumers, will apps soon be a thing of the past? 
 
Curious about how what it would take for your company to upgrade to a Progressive Web App? [Let’s talk](https://dockyard.com/contact/hire-us).
