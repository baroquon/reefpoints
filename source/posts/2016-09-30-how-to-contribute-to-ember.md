---
layout: post
title: 'How to Contribute to Ember'
summary: 'A brief guide on how to contribute to open source software'
author: 'Doug Yun'
twitter: 'dougyun'
github: duggiefresh
published: true
tags: engineering, open source, ember
---

## tl;dr

There are numerous ways to contribute to open source software. You can do one of
the following:

1. Engage, Help and Teach
1. Write articles and improve learning resources
1. Create and comment on issues
1. Contribute code
1. Build the community

Today, we'll use Ember as an example. To find out ways to aid the Ember community,
read more below!

## Open Source is Used by Everyone

A majority of the tools we use at DockYard are open source software (OSS) and we
love [giving back to the community][dockyard-oss]. If you're reading this post,
the chances that you are using OSS are pretty darn high. Just take a look at the
Wikipedia page for [the list of free and open source software packages][wikipedia].
It's safe to say that OSS is used by a bizallion companies each day!

## Examples of OSS at DockYard

Some highlights of DockYard's current stack includes [Elixir][elixir-website],
[Phoenix][phoenix-website], and [Ember][ember-website]. Not only do we utilize these
tools to build [amazing applications][amazing-work], we also contribute back to these
fantastic organizations.

If you're interested in Elixir, I recommend checking out Brian's post entitled
[How to contribute to Elixir][contribute-elixir]. In that post, he goes over his
experience contributing code to the language.

## Cheesy Call to Action: What Can You Do?

Today, we'll touch upon a few basic ways to contribute back to the Ember community.

If you're a beginner to open source, have no fear! I have had the great fortune
of working with some amazing OSS contributors, who all started out inexperienced,
yet, have grown to become open source powerhouses.

## Let's Start Contributing (to Ember)

Ember has been around for while (some say as early as 2011), and as expected,
has greatly matured. From recommended tools to best practices, Ember's
ever improving wave has been a wild, yet relatively safe ride. I've been working
with Ember before it was cool, and can share my personal experience
with helping out the community.

![](https://i.imgur.com/Y2Zr7NA.jpg)

_Thanks, [Hassan][hassan-twitter] for the hilarious infuriated Tomster_

### Engage, Help and Teach

The [Ember community page][ember-community-page] lists various places where users
can chat, discuss, or ask questions. However, it should be noted that from my experience,
IRC and discussion forum do not receive as much traffic as the [Slack community][ember-slack].

I recommend using the Slack community as the number one communication resource.
There are numerous channels that range from local user groups to
testing practices. I suggest examining the channels you'd like to belong to, and engage with
fellow users.

The `#-help` channel is a great place to ask Ember-related questions.
Furthermore, there are plenty of opportunities to help and teach your fellow developers
about Ember.

![](https://i.imgur.com/Hxw1qtd.png)
_A real life enactment of someone helping another person in the Ember Slack community_

### Write articles and improve learning resources

I have read my fair share of articles based upon web development (I have stopped
reading any articles about JavaScript fatigue though). I imagine many of us have
learned a great deal from articles detailing one cool trick by a seasoned developer,
or an article describing the pros and cons of a given programming language.
My point is that so many of us learn from consuming blog posts, articles, etc.

So, add to the sea of knowledge, and write something you know about. Heck,
I'm doing that right now! And, if someone has [already written about a topic
you care about][mixonic-article], perhaps you can offer another perspective
or additional advice.

The [Ember guides][ember-guides-site] are [open sourced on GitHub][ember-guides-gh],
and there are plenty of [issues marked as "help-wanted"][ember-guide-issues].

### Create and Comment On Issues

Just like any other open source project, Ember and its associated libraries, receive
a [high number issues][ember-issues]. Luckily, we can help out!

Let's say you happen to run into a "bug", what should you do next? First, search through
the existing issue tracker for the given project, and [attempt to find your issue][obligatory-xkcd].
If you find your issue, add a comment!

Thorough comments on a particular issue can help tremendously. If you see a comment, and
are experiencing the same issue, please don't bombard the maintainers with a "+1" comment.
Instead, offer something more insightful. You can attach an [Ember Twiddle][ember-twiddle]
in an effort to recreate the issue, and state your expectation vs. actual behavior.

If you can't find an existing issue that replicates yours, create a new one.
Ember actually has a [good recommendation on issue reporting][ember-issue-reporting].
Following these steps helps to ensure that your issue can be recreated and corrected
as soon as possible. Moreover, it opens up the opportunity for others from the community
to solve your issue.

### Contribute Code

Submitting [pull requests to Ember libraries is straightforward][ember-pr-guide].
There is a channel within the Slack community called `dev-ember` that is reserved
for the discussion of "development on Emberjs itself."

So long as you follow the aforementioned guidelines, submitting a PR is an easy
process.

Just like any other code base, Ember libraries can be intimidating at first, however
with enough persistence, you'll be cooking in no time! In addition, "contributing
code" can take the form of [contributing documentation][ember-issues-docs].

Lastly, if you stick around, the maintainers occasionally ask for community help,
and you'll be rewarded with a great opportunity to help out.

![](https://i.imgur.com/KRQr2p6.png)

_Please Ember community... you're my only hope_

### Build the community

When I say building the community, I mean you don't necessarily need to go
out and create a whole new meetup, or start a brand new conference (though
those are all good things). There are other less exhausting methods of
building and improving the Ember community.

There are various meetups to join, and plenty of ways to contribute.
Submitting a talk - whether it is a conference proposal or a lightning talk -
will allow you to broadcast your experiences with Ember, and help generate new discussions.
Secondly, I enjoy attending local meetups and conferences as it gives me the chance to
place faces with GitHub, Twitter, and Slack handles.

## Fin

Hope you found this article helpful! And before you go, our entire blog is open sourced,
so if you find a typo or want to make a suggestion, [please feel free][reefpoints]!

[dockyard-oss]: https://github.com/dockyard
[wikipedia]: https://en.wikipedia.org/wiki/List_of_free_and_open-source_software_packages
[elixir-website]: http://elixir-lang.org/
[phoenix-website]: http://phoenixframework.org
[ember-website]: http://emberjs.com
[amazing-work]: https://dockyard.com/work
[contribute-elixir]: https://dockyard.com/blog/2016/02/02/how-to-contribute-to-elixir
[hassan-twitter]: https://twitter.com/habdelra
[ember-community-page]: http://emberjs.com/community/
[ember-slack]: https://ember-community-slackin.herokuapp.com/
[mixonic-article]: http://madhatted.com/2014/11/5/contribute-to-ember-js-2-0-no-coding-required
[ember-guides-site]: https://guides.emberjs.com/
[ember-guides-gh]: https://github.com/emberjs/guides
[ember-guide-issues]: https://github.com/emberjs/guides/issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22
[ember-issues]: https://github.com/emberjs/ember.js/issues
[ember-twiddle]: https://ember-twiddle.com/
[obligatory-xkcd]: https://xkcd.com/979/
[ember-issue-reporting]: https://github.com/emberjs/ember.js/blob/master/CONTRIBUTING.md#issues
[ember-pr-guide]: https://github.com/emberjs/ember.js/blob/master/CONTRIBUTING.md#pull-requests
[ember-issues]: https://github.com/emberjs/ember.js/issues
[ember-issues-docs]: https://github.com/emberjs/ember.js/labels/Documentation
[ember-help-us]: https://github.com/emberjs/ember.js/issues/13127
[reefpoints]: https://github.com/dockyard/reefpoints