---
layout: post
title: "Live Search with Ember & JSON API"
social: true
author: Romina Vargas
twitter: "i_am_romina"
github: rsocci
summary: "Build a JSON API-compliant live search using Ember and
Phoenix/Rails"
published: true
tags: engineering, ember, javascript, phoenix, rails
comments: true
---

Live search is a feature commonly found in applications. There are various
solutions to implementing search functionality on a website, but "live search"
promotes a better user experience over the traditional way of searching
(i.e. type in keyword and click to view results); it's satisfying to a user
since immediate feedback is received based on what they have typed, without
having to click some form of a "submit" or "search" button. It's refreshing to
see results narrow as you type more words, or broaden as you backspace to delete
already-typed characters from the search box. The less work your user
has to do, the better.

Live search is not new concept whatsoever, but if you're new to the
[JSON API specification][jsonapi-spec] and would like to follow its conventions,
this may be helpful.

The specification states the following on the subject of filtering:

* The `filter` query parameter is reserved for filtering data.
* Servers and clients **SHOULD** use this key for filtering operations.

Given that info, we'll go over how to set up the client-side (Ember), and the
server-side (in both Phoenix and Rails) to get live search working. In the
following examples, we'll work with a `Food` model having a `category` attribute.

## On the Ember side

To get started, make sure your application is using the `DS.JSONAPIADAPTER`;
it's the default adapter in a new Ember application. This informs your
application of the type of data that it should be expecting from the server. In
our case, the payload will be expected to have a specific format and will be
expected to contain certain keys. Check out the [spec][jsonapi-spec] if you'd
like more details on this.

Having that, we only need to add a couple of things:
[query parameters][query-params] and the call to the server itself.

```js
// controllers/foods.js
import Ember from 'ember';
const { Controller } = Ember;

export default Controller.extend({
  queryParams: 'category',
  category: ''
});
```

```js
// routes/foods.js
import Ember from 'ember';
const { Route } = Ember;

export default Route.extend({
  queryParams: {
    category: { refreshModel: true }
  },

  model(params) {
    return this.store.query('food', { filter: { category: params.category } });
  }
});
```

It's that simple. Notice that we're using the store's `query` method and
providing it with a `filter`. This `filter` **must** be included in the call.
This will result in a `GET` request containing a URL encoded string with the
`filter` query parameter:

`/foods?filter%5Bcategory%5D=pastry`

Now let's see how to set this up on the backend for a seamless integration.

## On the Phoenix side

* Hex package needed: [ja_resource][ja-resource]
* Recommended to use with: [ja_serializer][ja-serializer]

After following the lib's quick installation instructions, and aside from
needing to add our route and schema, that's all we need to do in Phoenix
before heading over to our controller for some filtering logic.

```elixir
defmodule MyApp.FoodController do
  import Ecto.Query

  use JaResource
  use MyApp.Web, :controller

  plug JaResource

  def filter(_conn, query, "category", category) do
    from f in query,
      where: ilike(f.category, ^("%#{category}%"))
  end
end
```

On L7, `plug JaResource` is reponsible for providing all the controller actions
by default. There is no need for you to implement these actions unless you'd
like to add custom logic. That's a pretty nice time saver!  Plus we can
customize our controller's behavior via the many callbacks that the library
provides. JaSerializer conveniently provides the callback `filter/4` where we
can handle our custom filtering given our filter parameters. In the example, we
only want to filter by category, so we add "category" as the third argument
so that we get a match. You'll have to define one of these filter callbacks for
as many filter parameters as you want to pass. "Anything not explicitly matched
by your callbacks will get ignored."

## On the Rails side

* Gem needed: [jsonapi-resources][jsonapi-resources]

After having installed the gem, like in the Phoenix section above, you'll need to
declare your routes and models. To gain the simplest form of the `filter`
functionality, you just need to add the following (L5) to the corresponding
resource file (this will find an exact match):

```ruby
class FoodResource < JSONAPI::Resource
  attributes :category

  filter :category
end
```

The filter will be based on the term passed in from the `GET` request coming
from the Ember side; it will make sure that we are only returned `Food` records
whose `category` value matches _exactly_ that of the request parameter
(i.e. "pastry").

Below, I show another example that leverages the `:apply` option whose
arguments are records (an `ActiveRecord::Relation`), the value to filter by,
and an options hash.  However, you have much flexibility on how you decide to
implement your filter. The [README filter section][jsonapi-resources-readme]
has a more comprehensive list of the possibilities.

```ruby
class FoodResource < JSONAPI::Resource
  attributes :category

  filter :category, apply: -> (records, value, _options) {
   records.where('category LIKE ?', "%#{value[0]}%")
  }
end
```

## Conclusion
That wraps it up! The Ember frontend and the Phoenix/Rails backends now work
together to provide a live search functionality to a web application. Since
we're following the JSON API spec, there is little to no friction on either
side in order to get this working as expected. Happy filtering!

[jsonapi-spec]: http://jsonapi.org/format
[query-params]: https://guides.emberjs.com/v2.8.0/routing/query-params/#toc_specifying-query-parameters
[ja-resource]: https://github.com/AgilionApps/ja_resource
[ja-serializer]: https://github.com/AgilionApps/ja_serializer
[jsonapi-resources]: https://github.com/cerebris/jsonapi-resources
[jsonapi-resources-readme]: https://github.com/cerebris/jsonapi-resources#filters
