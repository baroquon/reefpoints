---
layout: post
title: 'Vim: Jump, Jump, Jump!'
comments: true
author: 'Doug Yun'
twitter: 'DougYun'
github: duggiefresh
social: true
summary: "Kris Kross' favorite Vim feature"
published: true
tags: vim, workflow
---

# <a href="https://www.youtube.com/watch?v=010KyIQjkTk" target="_blank">Jump, Jump, Jump!</a>

In the last Vim-related post, we
[discussed **mark** motion](http://reefpoints.dockyard.com/2014/04/10/vim-on-your-mark.html),
and today, we're going to cover another type of navigation: **jump** motion.

The main benefit of jump motion is its speed; it allows us to quickly traverse through the current file
open or previously visited files.

Let's briefly cover some of the most familiar ones.

## File Jumps

*File jumps* will navigate you to a location within the current file, regardless if that
location is seen or not seen within the window.

### <a href="https://www.youtube.com/watch?v=Xz-UvQYAmbg" target="_blank">Ain't no Mountain high enough, ain't no valley low enough...</a>

**gg**

* Will take you to the *top* of the file.

**G**

* Will take you to the *bottom* of the file.

### Sentences and Paragraphs

**(**

* Move a *sentence backwards*, can take a prefix argument.
  * **5(** - Navigates you 5 sentences backwards.

**)**

e Move a *sentence forward*, can take a prefix argument.
  * **10)** - Navigates you 10 sentences forwards.

**{**

* Move a *paragraph backward*, can take a prefix argument.
  * **5{** - Navigates you 5 paragraphs backwards.

**}**

* Move a *paragraph forward*, can take a prefix argument.
  * **5}** - Navigates you 5 paragraphs forwards.

### <a href="https://www.youtube.com/watch?v=EDNzQ3CXspU" target="_blank">Search and Destroy</a>

**/**

* Allows you to search *forwards* for a desired pattern within the file.
  * **/fishsticks** - Searches for all occurences of `fishsticks` ahead of your current cursor.

**?**

* Allows you to search *backwards* for a desired pattern within the file.
  * **?catdog** - Searches for all occurences of `catdog` behind your current cursor.

**n**

* Repeats the last **/** or **?** search.

**N**

* Repeats the last **/** or **?** search in the *opposite* direction.

## Window Jumps

*Window* jumps allow you to move within the current scope of the window or viewport.

### <a href="https://www.youtube.com/watch?v=JECF2EB3LXU" target="_blank">High, Middle, and Low</a>

**H**

* Jumps your cursor to the **highest** line of the window.

**M**

* Jumps your cursor to the **middle** line of the window.

**L**

* Jumps your cursor to the **lowest** line of the window.

## System Wide Jumps

*System* jumps are special; they have the ability to take us to any previously visited file,
regardless if those files are or are not within the same directory.

This is where jump motion really shines!

### <a href="https://www.youtube.com/watch?v=KZaz7OqyTHQ" target="_blank">Jump Around</a>

Give these next commands a try:

**CTRL-O**

* Jump to our previous position.

**CTRL-I**

* Jump to our next postion.

By pressing these commands repeatedly, you'll see that you are traversing through
your recently visited files.

### Jump list

Our recent jumps are stored on our *jump* list. We can view all the jumps through Vim's
command-line mode. There are three ways to open up the jump list.

**:jumps**

**:jump**

**:ju**

* Opens up the jump list

![](https://i.imgur.com/mFc1cHz.png)

Above is an example of a jump list. There are four columns: *jump*, *line*, *col* and *file/text*.
The numbers underneath the *jump* column are used to prefix our jump command, **CTRL-O** and **CTRL-I**.
We are also given the position of our cursor from the  *line* and *col*umn columns. Lastly, the
*file/text* column, gives us either the file path or, if the jump is located in our currently opened file,
the line of text.

Using our example jump list, if we want to jump to the `4`th jump, located within `~/dir2/file.md`, we'd
prefix our previous jump command with the number **4**, i.e. **4CTRL-O**.

Next if we want to get back to our previous position, the line
`This is another sentence!` we can cycle back to it with a couple of **CTRL-I**s. Cool!

I find that *jump* motion complements *mark* motion really well. By setting multiple marks in the current file,
and flying to different files with jumps, my workflow has greatly improved.

Hope you give *jump* motion a try!
