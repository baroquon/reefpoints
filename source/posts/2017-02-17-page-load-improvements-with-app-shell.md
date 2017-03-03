---
layout: post
title: "Improving Ember app page load times using the App Shell model"
social: true
author: Marten Schilstra
twitter: "martndemus"
github: martndemus
summary: "Experimenting with the App Shell model to make the DockYard.com website load faster"
published: true
tags: JavaScript, Ember, PWA
---
*In the past week I have been experimenting with the [App Shell Model](https://developers.google.com/web/fundamentals/architecture/app-shell) to make the [DockYard.com](https://dockyard.com) website load faster. In this blog post I'll walk through which changes I made and how I've made them. Complete with some benchmarks!*

### Why improve page load speed?

According to Google, if [loading a page takes too long](https://www.thinkwithgoogle.com/articles/mobile-page-speed-load-time.html), they'll just abandon it. This hurts your conversion rates. Key metrics that contribute to better conversion rates are when the browser is able to make its first paint and when the page is fully loaded.

### Tools of the trade

*In this section I'll introduce the tools I've used to measure the loading performance. Please take a minute to follow the links to the mentioned tools and read how they work and what they are for.*

To be able to measure the performance of DockYard.com I have used [Lighthouse](https://developers.google.com/web/tools/lighthouse/) and the [Application](https://developers.google.com/web/fundamentals/getting-started/codelabs/debugging-service-workers/), [Network](https://developers.google.com/web/tools/chrome-devtools/network-performance/) and [Timeline](https://developers.google.com/web/tools/chrome-devtools/evaluate-performance/timeline-tool) DevTools from the Google Chrome team to see changes made a positive impact on loading speed.

Lighthouse is the successor of Google's [PageSpeed](https://developers.google.com/speed/pagespeed/) tool. Lighthouse uses your Chrome DevTool to do a host of automated audits. I.E. it checks if a [Service Worker](https://developers.google.com/web/fundamentals/getting-started/primers/service-workers) is registered and that a [Web App Manifest](https://developers.google.com/web/updates/2014/11/Support-for-installable-web-apps-with-webapp-manifest-in-chrome-38-for-Android) can be found. The audits I'm most interested in are the page load performance audits. These measure the [first meaningful paint](https://developers.google.com/web/tools/lighthouse/audits/first-meaningful-paint), the [speed index](https://developers.google.com/web/tools/lighthouse/audits/speed-index) and [time to interactive](https://developers.google.com/web/tools/lighthouse/audits/time-to-interactive) performance.

### What I'm measuring

I'm measuring the page load in two situations. The first situation is as if it's the very first time I'm visiting the website, this means no assets have been cached yet. The second situation is when I'm loading the website on a repeat visit, which means the browser had a chance to cache the assets. I'll also measure the same two scenarios using network and CPU throttling to simulate being out and about on a mobile device. Mobile simulation is done on the 'Regular 3G' network throttling setting and the 'Low end device' cpu throttling setting.

There are three key performance metrics I'm looking for in each test, first I'll look for when the first meaningful paint happens and second I'll look for the moment when the Ember.JS app has booted client side and when the Ember.JS app has done its initial render on the client side. The first meaningful paint and the initial render metric are the two metrics that according to [Google](https://www.thinkwithgoogle.com/articles/mobile-page-speed-load-time.html) contribute the most to abandonment rate.

### Getting the baseline

*Benchmarks have been made on a standard mid 2015 15" MacBook Pro, all tests have been done with a wired 500 megabit up/down internet connection. I have about 90ms latency towards the webserver and about 7ms to the assets server.*

To start out, here are the baseline performance metrics of the current DockYard.com website. It is a Ember.js application that is served with [FastBoot](https://ember-fastboot.com).

#### Baseline Lighthouse score

![](http://i.imgur.com/GNrFsfe.png)

*Note: Lighthouse measures without CPU slowdown and a custom network throttling setting*

This initial lighthouse score shows that the first meaningful paint comes just before the time to interactive. This does mean that when the page shows up, it's almost immediately interactive, but you'll see nothing before that.

#### Baseline Desktop: Page load with empty cache

![](http://i.imgur.com/pRF7ak0.png)

- First paint: 600ms
- App boot: 1,175ms (the dip in the CPU graph)
- Initial render: 1,400ms
 
#### Baseline Desktop: Page load with warmed cache

![](http://i.imgur.com/LQVYcYN.png)

- First paint: 325ms
- App boot: 750ms
- Initial render: 950ms
 
#### Baseline Mobile: Page load with empty cache

![](http://i.imgur.com/LNL0fSB.png)

- First paint: 1,200ms
- App boot: 8,900ms
- Initial render: 10,200ms
 
#### Baseline Mobile: Page load with warmed cache.

![](http://i.imgur.com/Z3Y9JZO.png)

- First paint: 850ms
- App boot: 2,850ms
- Initial render: 4,200ms
 
### The changes I've made

First off I've added (offline) caching by a Service Worker, using [Ember Service Worker](http://ember-service-worker.com) with various plugins. This did not, as expected, improve the cold boot scenarios, but did improve the scenarios with warmed cache slightly. Especially the first paint was much earlier. Results of the warmed cache scenarios are:

#### Service Worker only Desktop: Page load with warmed cache

![](http://i.imgur.com/oasoMXS.png)

- First paint: 125ms
- App boot: 725ms
- Initial render: 900ms
 
#### Service Worker only Mobile: Page load with warmed cache

![](http://i.imgur.com/Hq8beZk.png)

- First paint: 300ms
- App boot: 2,700ms
- Initial render: 4,000ms
 
Next I wrote a small [Ember CLI addon](https://github.com/DockYard/ember-cli-one-script) that concats both scripts (`vendor.js` and `dockyard.js`) that Ember CLI produces together. Then I proceeded to load that single JavaScript file using a `` element in the head that was marked `async`. This had no significant improvement on the desktop side, but loading on mobile did improve. There is a small downside to this technique though, the two files aren't cached seperately by the browser anymore, which can increase the amount of data needed to be transferred when deploying new builds often.

#### Async'ed script Mobile: Page load with empty cache

![](http://i.imgur.com/s6Uq246.png)

- First paint: 750ms
- App boot: 7,950ms
- Initial render: 9,000ms
 
#### Async'ed script Mobile: Page load with warmed cache

![](http://i.imgur.com/me4jkYA.png)

- First paint: 200ms
- App boot: 2,350ms
- Initial render: 3,550ms
 
Lastly I extracted all the critical CSS for an initial render and inlined it into the `` section. Then proceeded to asynchronously load the remaining CSS using [loaddCSS](https://github.com/filamentgroup/loadCSS). This made the first paint come slightly earlier in all scenarios, but hurts the initial render by about 150ms on mobile.

#### Async'ed CSS Desktop: Page load with empty cache

![](http://i.imgur.com/IykzFzl.png)

- First paint: 550ms
- App boot: 1.100ms
- Initial render: 1.325ms
 
#### Async'ed CSS Desktop: Page load with warmed cache

![](http://i.imgur.com/jSl4eiJ.png)

- First paint: 125ms
- App boot: 675ms
- Initial render: 900ms
 
#### Async'ed CSS Mobile: Page load with empty cache

![](http://i.imgur.com/Y9vAfls.png)

- First paint: 500ms
- App boot: 8,100ms
- Initial render: 9,150ms
 
#### Async'ed CSS Mobile: Page load with warmed cache

![](http://i.imgur.com/j9JCLsg.png)

- First paint: 125ms
- App boot: 2,500ms
- Initial render: 3,700ms
 
#### All the stats summed up in a table

![](http://i.imgur.com/7NTHg9u.png)

#### Final Lighthouse score

![](http://i.imgur.com/B2dq8p5.png)

*Note: To get the perfect 100/100 score we also added a Web App Manifest.*

That's an impressive 10x speed up in first paint and almost a second and a half in time to interactive. This gives your user much more confidence in that your page is loading.

### Browsers without Service Worker

You might ask: "How does this affect page loading in browsers that not yet support Service Workers?". I've tested the before and after with Safari's timeline tool. The results show no significant speed up in full page load, but actually a slight slowdown. The results do show a significant speed up in first paint time with either empty or warm cache.

After the benchmarks I've noticed that loading the service worker registration script plays a big part in the slowdown. I'd need to fiddle some more with loading that script to see if I can get rid of the slowdown.

Below are the timeline graphs for loading in Safari. Notice the big shift of the blue `DOMContentLoaded` line. That counts as the first paint. The red `Load` line is the app boot. The last green bar is the initial render.

#### Baseline: Page load with empty cache

![](http://i.imgur.com/Skyo7Dk.png)

- First paint: 510ms
- App boot: 600ms
- Initial render: 740ms
 
#### After improvements: Page load with empty cache

![](http://i.imgur.com/AZuSkqW.png)

- First paint: 250ms
- App boot: 650ms
- Initial render: 820ms
 
#### Baseline: Page load with warm cache

![](http://i.imgur.com/dE536q5.png)

- First paint: 510ms
- App boot: 575ms
- Initial render: 730ms
 
#### After improvements: Page load with warm cache

![](http://i.imgur.com/QcDuWBI.png)

- First paint: 250ms
- App boot: 620ms
- Initial render: 780ms
 
#### Safari tests summarized

![](http://i.imgur.com/kZT1iWE.png)

### Conclusion

A Service Worker and a bit of techniques from the App Shell model can boost your page load times. Your app will show up on the screen earlier and be interactive quicker, which in turn can improve the conversion rates of your website.

Please try out these techniques and see for yourself if it improves page load times of your app. In any case let me know how it works out for you.

Closing: don't forget to compress your images, svg's and fonts! Those too can impact page load performance by seconds on mobile.
