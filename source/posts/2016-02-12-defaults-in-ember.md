---
layout: post
title: "Ember Data: Worryless Model Defaults"
social: true
author: Romina Vargas
twitter: "i_am_romina"
summary: "Take some precaution when setting object and array defaults on Ember Data
models"
github: rsocci
published: true
tags: ember, javascript, best practices
ember_start_version: 1.4
---

When working with Ember Data models, it’s common to want to set default values for
certain attributes. Setting a default value on a model is super easy and
you've probably done it countless times:

```js
import Model from 'ember-data/model';
import attr from 'ember-data/attr';

export default Model.extend({
  isHungry: attr('boolean', { defaultValue: true })
});
```

The above syntax works flawlessly for `Boolean`, `String`, and `Number`
types. But what if you want to set defaults on an `Object` or an
`Array` type?

Before answering that question, you should note that Ember Data does not
have out of the box support for `Object` and `Array` types. Well, kinda.
If you don't specify a type as the first argument to `DS.attr`, it just
means the value for that attribute will be untouched rather than coerced
to the matching JavaScript type. You can easily add a
[transform][transforms] for a custom type. _Your transform should provide
serialize and deserialize methods for proper processing_.

Now to answer the above question, your first instinct might be to do the
following:

```js
// app/models/person.js
import Model from 'ember-data/model';
import attr from 'ember-data/attr';

export default Model.extend({
  favoriteThings: attr('object', { defaultValue: {} })
});
```

Here, every new record created with the `Person` model would be expected to have a
`favoriteThings` value of `{}`, rather than `undefined`. Which is correct, but
only until you begin setting content on that object. An Ember Data model extends
from `Ember.Object`, meaning that arrays and objects will be shared among
all instances of that model. If you're not too familiar with that concept,
check out this past Ember Best Practices [blog post][leakingstate] from Estelle!

The result from setting a model attribute default to an empty object:

```js
let foo = this.store.createRecord('person');
get(foo, 'favoriteThings'); // => {}
set(foo, 'favoriteThings.food', 'pozole');
get(foo, 'favoriteThings'); // => { food: 'pozole' }

let bar = this.store.createRecord('person');
get(bar, 'favoriteThings'); // => { food: 'pozole' }
```

Trolling at its finest. Bar doesn't even know what "pozole" is. (By the way, if you've
never had Mexican [pozole][pozole], you're missing out!)

This quirky functionality isn't particular to Ember, however. It all stems from
JavaScript itself; this also happens with POJOs:

```js
var foo = { name: 'foo' };
var bar = foo;

bar.name = 'bar';

console.log(bar); // { name: 'bar' }
console.log(foo); // { name: 'bar' }
```

Lucky for us, Ember has made it easier to avoid this pitfall by deprecating the use of a
complex object as a default value for a model property. If you try to set an attribute with
a default value of type `"object"`, you'll see a warning message: `Non primitive
defaultValues are deprecated because they are shared between all instances. If you would
like to use a complex object as a default value please provide a function that returns the
complex object.` This is your cue to undo.

## A better, and often forgotten option

Don't fret, because this issue is just a simple fix away. `defaultValue` also accepts
a function. Hooray! Let's modify our code to work as we would expect.

```js
// app/models/person.js

import Model from 'ember-data/model';
import attr from 'ember-data/attr';

export default Model.extend({
  favoriteThings: attr('object', { defaultValue: () => {} })
});
```

That's it! This will ensure that every `favoriteThings` attribute contains its own object
instance. Having the ability to pass in a function to `defaultValue` can also
prove helpful if you would like to set custom defaults based on computed
properties, as well as other attributes of the same model.

Hope this served as a sweet reminder, or as something new that you can leverage
in your projects from now on.

[transforms]: https://guides.emberjs.com/v2.3.0/models/defining-models/#toc_transforms
[leakingstate]: https://dockyard.com/blog/2015/09/18/ember-best-practices-avoid-leaking-state-into-factories
[pozole]: https://en.wikipedia.org/wiki/Pozole
