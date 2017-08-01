---
layout: post
title: "Part 1: Should you use Ember FastBoot or not?"
social: true
author: Brian Cardarella
twitter: "bcardarella"
github: bcardarella
summary: "Ember FastBoot comes with trade-offs. Let's explore if your app is the right candidate for FastBoot."
published: true
tags: ember
---
 
<a href="https://www.youtube.com/watch?v=OInJBwS8VDQ&t=41m10s">DockYard.com was one of the world's first production FastBoot enabled applications</a>. We have had signifcant experience building FastBoot enabled websites for us and our clients. Over the course of that time I have developed "opinions" on when apps should use FastBoot and if the costs are too high to implement it.

Let's start with agreeing on what FastBoot gets you: Server Side Rendering (SSR). The value of SSR to your company depends upon what your revenue model is. More likely than not this value is going to be tied to your SEO score. Ensuring that your app can be crawled by the most popular search engines is very important to many businesses. FastBoot will also help improve the <a href="https://developers.google.com/web/tools/lighthouse/audits/first-meaningful-paint">First Meaningful Paint</a> on your app. This has a direct impact upon Page Rank, Conversion Rate, Bounce Rate. In other words, the faster your content is available to your visitors improved the quality of their visit.

However, it is not all gravy. There are significant costs to building and maintaining a FastBoot enabled Ember app and that's what I will discuss over this series of blog posts. Too often I am seeing developers struggle with building, maintaining, and deploying a properly built FastBoot Ember app. Do you even need FastBoot for your given context? Is the ROI the same as without SSR for your customers or can you get similar or better ROI by going the route of a Progressive Web App?

There are future benefits that FastBoot will eventually yield. For example, we can imagine a future where FastBoot can deliver specially built asset packages that are customized for the route your visitors access. If you visit just one section of a much larger content site why should you incur the cost of downloading bytes you don't need? However, this is not a reality as of today and is likely very far off in the future so we will not be taking features like this or other future features into consideration when weighing the cost/benefits. You are building an application today so we need to view the technology as of today and what comes with it.

I feel compelled to add a notice here: this isn't intended to be an indictment of FastBoot. I respect the time, effort, the team, and engineering complexity that has gone into building this technology.

Tomorrow we will delve into the costs of FastBoot and weighing them against real-world uses cases.