---
layout: post
title: "Part 2: Should you use Ember FastBoot or not?"
social: true
author: Brian Cardarella
twitter: "bcardarella"
github: bcardarella
summary: "In this part we'll look at the performance considerations for FastBoot and the ROI for your use-case."
published: true
tags: ember
---

<a href="https://en.wikipedia.org/wiki/Time_To_First_Byte">Time To First Byte</a>. If you are unfamiliar with this term, it is simply how long does it take the server to start respondnig back with the first byte of the request. With certain advances in technology like HTTP/2 TTFB has become less of an issue because you can load all of your assets in parallel.  With HTTP/1.1 you had to wait for each asset to finsh being received before requesting the next. As you can imagine, the longer it takes to even start receiving your asset, let alone the time it takes to get the entire asset, can really accumulate.

TTFB becomes an issue for any FastBoot enabled web app because the `index.html` that it serves has all of the rules on what to download next. The browser cannot download in parallel assets it hasn't yet been instructed to fetch. So while the actual transfer time of the given `index.html` files from FastBoot may be trivial, especially when gzipped, the latency to start receiving the file can really add to the overall impression of how performant your application is. Let's look into why this is, how much latency FastBoot adds, and some strategies around this.

### Why is there any TTFB delay?

Keep in mind what FastBoot is doing. When your browser requests the URL it will hit the FastBoot server. FastBoot then starts a new Ember app (more on this later), routes based upon the requested URL, may make one or more external requests via Ember Data to an API, renders the page, and returns it. This is a typical render cycle for any server-side application (with the exception of instantiating a new app) and shouldn't be looked at in any other way. We *must* incur this cost if we want to render the uniquely rendered page for the given URL.

What is less understood at this point is what we probably shouldn't be incurring the cost of. And that falls back to the Ember app being instantiated on each request. In my opinion, the community is still very early in the process of learning how best to use and optimize Ember server-side. The big challenge was to get Ember working with SSR in a stable way. <a href="https://emberjs.com/blog/2017/07/19/ember-fastboot-1-0-release.html">With FastBoot 1.0 recently being released</a> that has been accomplished. I'd like to see a focus on server-side rendering performance.

### How much latency does FastBoot add?

The answer to this question is, as it is with most things in life, "it depends". There are different scenarios. For example, is this the first request to the URL? Is it the 10th request? Are you making external requests, if so how many? So to help inform this let's look at the most basic use case: a first time request (cold) to the app with a newly generated Ember app: **100ms** on my machine. The 2nd request reduces to roughly **60ms**. The 10th request bring it down to around the **10ms** mark.

These numbers are very far apart. Without getting into the source we can assume that Node or Express is making some run-time optimizations based upon code it is seeing more frequently. We don't have any caching set up and FastBoot is not written to boost performance on additional renders. FastBoot does do a one-time `initilize` of your app, so it is now in a state of pre-instantiation but has gotten some of the work out of the way. This is why pushing work out of `instance-initializers` to `initilaizers` is important if you don't need app state and want to avoid repeat cost.

This is all before you have actually written any business logic in your app. On this site on a warm FastBoot instance (10+ requests for the given URL) fetching `index.html` averages out to above **500ms**:

![](http://i.imgur.com/qcBJGBK.png)

So, not great. Especially considering that we are not doing that much. We make very few network requests and don't have too many complex components to render.

The TTFB can directly impact the time it takes to render your app, and crawlers like Google take this time into consideration as part of their PageRank score. Its important to try and reduce this as much as possible.

### Some strategies to improve FastBoot performance

The nice part about getting Ember rendering on the server is that anything you do to improve the performance of the app in the browser will improve the performance of the app on the server. Two birds, one stone. I would start there. Use the <a href="https://github.com/emberjs/ember-inspector">Ember Inspector</a> to help measure your app's performance and identify rendering issues.

Next, you should take a look at your network requests. How performant are they? The SSR app will block on their responses. If your API is not fast it is just having a cascade affect on everything else. We use <a href="http://phoenixframework.org/">Elixir / Phoenix</a> so our average API resonse times are **&#60; 1ms** (I'm not joking).

Once you've tuned your API to be as fast as possible, there are some decisions to make. A change that fellow DockYarder <a href="http://twitter.com/MiguelCamba">Miguel Camba</a> landed in FastBoot was an extraction from a recent client project. The idea is detailed in <a href="https://github.com/emberjs/rfcs/pull/185">an RFC I opened a while back</a>. The basic idea is if you have a proxy server in front of your FastBoot server and that proxy has access to the data it can mutate the `GET` request into a `POST` request and embed the data in the `body` of the request. There are complexities here for sure, your proxy has to be smart enough to know what resources are necessary to embed based only upon the URL requested. Does it make sense to duplicate this business logic in both the app and the proxy server? Again, it depends. The benefit is getting rid of the outbound request your Ember app would make. This would have been an HTTP request and that carries its own overhead with it. <a href="https://dockyard.com/contact/hire-us">If you are interested in the Post to FastBoot functionality please talk to us, we're happy to help</a>.

The last recommendation is one that can either be simple to do or <a href="https://martinfowler.com/bliki/TwoHardThings.html">one of the hardest problems in Computer Science to solve</a>. With a Content Delivery Network (CDN) such as Cloudfront or Fastly you can serve your requests from the CDN and have the CDN request for the newer resource from your server. This can significantly cut down on the TTFB time by an order of magnitude. Those 500ms requests would be closer to single digit ms if we were doing this. It is our intention to do so, but we haven't fully done so yet. Why? Because we need to properly model how and when the cache would expire.

DockYard is a content driven site. We don't make a lot of content updates (other than blog) but when we do we want them immediately available. So we would need a way to inform the CDN when a given resouce is stale and it should re-fetch on the next request. This would require us to do so on any deploys of the Ember app. But then build a notifier for our backend Phoenix app for any blog updates or other contnet related changes. Our use case is not terribly complex, but just one we haven't yet had the dev cycles to do properly.

In any event, CDN caching would be my recommendation on how to improve the TTFB performance for FastBoot. But again, what is your context? Maybe you are a big time content generator who only has very short-term cache cyles. So even with the intermittant performance boost of the CDN the amount of traffic you receive could still be trashing the FastBoot server. This brings us back to the original question of if you need FastBoot or not. Tomorrow we'll discuss app design use cases that are likely mis-using FastBoot. Maybe you fall within this category?