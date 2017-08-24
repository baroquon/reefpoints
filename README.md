# DockYard's ReefPoints Blog #

## Getting Setup ##

```shell
$ mix deps.get
```

## Getting Up & Running ##

```shell
$ mix build
```

## Markdown

All blog posts are written in markdown. We use GitHub's flavor of
markdown; here's a handy guide: [Mastering
Markdown](https://guides.github.com/features/mastering-markdown/)

## Want to make your own post? ##

### The GitHub web interface way

* [Click here](https://github.com/dockyard/reefpoints/new/master/source/posts) to be brought to the new post page
* Title your file following the pattern `<date>-<title with dashes>.md`,
  an example of this would be `2015-01-01-my-awesome-blog-post.md`
* Add the following block to the beginning of the file, this block
  contains the meta data for the post:
```
---
layout: post
title: "My Awesome Blog post"
social: true
author: Jane Doe
twitter: "janedoe"
github: janedoe
summary: "A brief summary of your post"
published: true
tags: tags, separating each, with commas
---
```

* Make sure publish is true, otherwise your blog post will not appear
* Place a new line underneath this meta data, and paste your content
* Scroll to the bottom, adding a commit message summary in the present
  tense `Adds my awesome blog post`
* Make this commit on a new branch by clicking the bottom radio button
  and giving the branch a name

![Committing a new file](https://monosnap.com/file/rY5xzq5B5ge9EpepCMpH410zb9eLZ0.png)

* At this point, you will be brought to the pull request page, click the
  'Create Pull Request' button

![Pull request creation](https://monosnap.com/file/lbBg9S9Aoe8e4HSthSDj1MltAKCGKz.png)

* Ask people to review your awesome new blog post

### The command line way

* Pull down the latest

```shell
$ git pull origin master
```

* Make a new branch

```shell
$ git checkout -b YOURNAME-your-topic-name
```

* Done writing? Now you can submit your PR...

```shell
$ git push origin YOURNAME-your-topic-name
```

* Open a PR on Github using [hub](https://hub.github.com)

```shell
$ brew install hub
$ hub pull-request -m "My awesome blog post" -b dockyard:master
```

* Or do it the old school way via the GitHub UI. Done getting feedback? Merge your branch into `master`.

## Adding images ##

* Upload the image(s) to [imgur](http://imgur.com/) and grab the URL. Be
  sure to include the image with HTTPS.

The maximum width for an image is `840px`.

## Tags ##

Tags will become categories once your post is published. Please refer to
existing tags when tagging your post. This will ensure that we don't
have multiple variations of the same tag (i.e., `ember` vs `Ember`).

## Legal ##

[DockYard](http://dockyard.com), LLC &copy; 2013

[@dockyard](http://twitter.com/dockyard)

[Licensed under the MIT license](http://www.opensource.org/licenses/mit-license.php)