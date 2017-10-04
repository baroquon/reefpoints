---
layout: post
title: "Building an Ember app with RailsAPI - Part 3"
comments: true
author: "Brian Cardarella"
twitter: bcardarella
github: bcardarella
legacy_category: ember
social: true
summary: "CUD, it isn't just for cows"
published: true
tags: javascript, ruby on rails
---

**This article was last updated on May 28, 2013 and reflects the state
 of Ember (1.0.0-rc4) and the latest build of Ember Data (0.13) as of
that date.**

[Fork the project on Github!](https://github.com/bcardarella/ember-railsapi)

[Use the app live on Heroku](http://ember-rails-api.herokuapp.com/)

In [Part 1](https://dockyard.com/blog/ember/2013/01/07/building-an-ember-app-with-rails-api-part-1.html) I showed you how to setup a `Rails-API` app for Ember.

In [Part 2](https://dockyard.com/blog/ember/2013/01/09/building-an-ember-app-with-rails-api-part-2.html) I showed you the basics of building an Ember app, reading from a backend API and displaying that information.

Today we're going to do some coding on the Rails side and the Ember side to add Creating, Updating, and Destroying records.

## Part 3 - The Big Finish

In [Part 1](http://reefpoints.dockyard.com/ember/2013/01/07/building-an-ember-app-with-rails-api-part-1.html) we setup the backend using [Rails API](https://github.com/rails-api/rails-api/). In [Part 2](http://reefpoints.dockyard.com/ember/2013/01/09/building-an-ember-app-with-rails-api-part-2.html) we built out the basics of an Ember app, reading from a remote data source and displaying that data. Now we're going to add the ability to Create, Update, and Destroy that data. This part will be a mix of Ember and Rails code.

*Note: If you have been following along that [Part 2](http://reefpoints.dockyard.com/ember/2013/01/09/building-an-ember-app-with-rails-api-part-2.html) was recently updated to reflect new changes to the Ember Router, you will need to go back and update your code. Absolute make sure to update your ember.js and ember-data.js dependencies as they have been updated on the github repo*

### Create ###

Let's start by adding a `Create` button to our index page:

```handlebars
{{#linkTo 'users.new' class='btn btn-primary'}}Create{{/linkTo}}
```

We need to add the proper route so the index page doesn't blow up. While we're in here we'll add the `edit` route as well.

```coffeescript
App.Router.map ->
  @resource 'users', ->
    @route 'new'
    @route 'edit',
      path: '/:user_id/edit'
    @route 'show',
      path: '/:user_id'
```

And now we can add the `UsersNewRoute`

```coffeescript
App.UsersNewRoute = App.UsersRoute.extend
  model: ->
    App.User.createRecord()
  setupController: (controller, model) ->
    controller.set('content', model)
```

Don't be fooled by the `createRecord()` call. This will not write anything to the backend. This call is simply used to create a new model. Now let's create the template `app/assets/javascripts/templates/users/new.hbs`

```handlebars
<h1>Create {{fullName}}</h1>
<form>
  <fieldset>
    <div>
      <label {{bindAttr for="firstNameField.elementId"}}>First Name</label>
      {{view Ember.TextField valueBinding='firstName' name='first_name' viewName='firstNameField'}}
    </div>
    <div>
      <label {{bindAttr for='lastNameField.elementId'}}>Last Name</label>
      {{view Ember.TextField valueBinding='lastName' name='last_name' viewName='lastNameField'}}
    </div>
    <div>
      <label {{bindAttr for='quoteField.elementId'}}>Quote</label>
      {{view Ember.TextArea valueBinding='quote' name='quote' viewName='quoteField'}}
    </div>
    <a href='#' {{action save}} class='btn btn-success'>Create</a>
  </fieldset>
</form>
<div class='page-header'></div>

<a href='#' {{action cancel}} class='btn btn-inverse'>Cancel</a>
```

Next we'll add `app/assets/javascripts/controllers/users/newController.coffeescript`

```coffeescript
App.UsersNewController = Ember.ObjectController.extend
  headerTitle: 'Create'
  buttonTitle: 'Create'

  save: ->
    @content.save().then =>
      @transitionToRoute('users.show', @content)
    
  cancel: ->
    @content.deleteRecord()
    @transitionToRoute('users.index')
```

The first two functions `save` and `cancel` are actions that are mapped in the template. Let's break down each:

* `save` will make a call to `this.store.commit()`. You will notice we are not modifying a model, assigning params, etc... as you would in a Rails app. Keep in mind that when you modify data that is bound in the form you are actually modifying the data in the model itself. The datastore in Ember needs to be directed when these modifications should be made "permanent", and because we are using the RESTAdapter Ember will attempt to write these changes to the backend.
* `cancel` If the user decides to not create a new user we must delete the record we created then transition to the `index` page.

[Learn more about the Ember Model Lifecycle](http://emberjs.com/guides/models/model-lifecycle)

Finally we're going to hook up the back end in `app/controllers/users_controller.rb`

```ruby
def create
  user = User.new(params[:user])

  if user.save
    render json: user
  else
    render json: user, status: 422
  end
end
```

It has been mentioned that `422` is the proper status code for validation failures. Personally I would prefer to use `respond_with` but it isn't part of the default Rails-API stack, [hopefully this will change](https://groups.google.com/forum/?fromgroups=#!topic/rails-api-core/QhPh2VG7yTU).

Now let's run our app and see how it goes.

![New1](http://i.imgur.com/kFC9arb.png)

Whoops, we have `undefined undefined` for the `fullName`. Let's set default values of an empty string in our user model:

```coffeescript
App.User = DS.Model.extend
  firstName: DS.attr('string', defaultValue: '' )
  lastName: DS.attr('string', defaultValue: '' )
  quote: DS.attr('string')
  fullName: (->
    "#{@get('firstName')} #{@get('lastName')}"
  ).property('firstName', 'lastName')
```

Now when we add data and create it will write to the back end, take us to the show page. When can then click `Back` and we can see the record has been automatically added to the collection on the `index` page.

Adding `Edit` should be straight forward now that we have done create. Start will adding the route:

```coffeescript
App.UsersEditRoute = Ember.Route.extend
  model: (params) ->
    App.User.find(params.user_id)
  setupController: (controller, model) ->
    controller.set('content', model)
    @controllerFor('application').set('currentRoute', 'users')
```

You'll notice that this route is identical to `App.UsersShowRoute` we wrote in Part 2, let's DRY this up

```coffeescript
App.UserRoute = Ember.Route.extend
  model: (params) ->
    App.User.find(params.user_id)
  setupController: (controller, model) ->
    controller.set('content', model)
    @controllerFor('application').set('currentRoute', 'users')

App.UsersShowRoute = App.UserRoute.extend()
App.UsersEditRoute = App.UserRoute.extend()
```

Next we'll add the edit link to `app/assets/javascripts/templates/users/show.hbs`

```handlebars
{{#linkTo 'users.edit' content class='btn btn-primary'}}Edit{{/linkTo}}
```

Now the edit template itself in `app/assets/javascripts/templates/users/edit.hbs`

```handlebars
<h1>Edit {{fullName}}</h1>
<form>
  <fieldset>
    <div>
      <label {{bindAttr for="firstNameField.elementId"}}>First Name</label>
      {{view Ember.TextField valueBinding='firstName' name='first_name' viewName='firstNameField'}}
    </div>
    <div>
      <label {{bindAttr for='lastNameField.elementId'}}>Last Name</label>
      {{view Ember.TextField valueBinding='lastName' name='last_name' viewName='lastNameField'}}
    </div>
    <div>
      <label {{bindAttr for='quoteField.elementId'}}>Quote</label>
      {{view Ember.TextArea valueBinding='quote' name='quote' viewName='quoteField'}}
    </div>
    <a href='#' {{action save}} class='btn btn-success'>Update</a>
  </fieldset>
</form>
<div class='page-header'></div>

<a href='#' {{action cancel target='controller'}} class='btn btn-inverse'>Cancel</a>
```

And now the controller `app/assets/javascripts/controllers/users/editController.coffee`

```coffeescript
App.UsersEditController = Ember.ObjectController.extend
  destroy: ->
    @content.deleteRecord()
    @store.commit()
    @transitionTo('users.index')

  save: ->
    @content.save().then =>
      @transitionToRoute('users.show', @content)

  cancel: ->
    if @content.isDirty
      @content.rollback()
    @transitionTo('users.show', @content)

  buttonTitle: 'Edit'
  headerTitle: 'Editing'
```

This controller looks similar to `App.UsersNewController` but let's explore the differences

* `save` here because the model already has an `id` we can commit to the datastore and transition.
* `cancel` instead of deleting the record we want to rollback to its previous state. And we can only rollback if the record has changed.

I'm sure you know what is next. The `new` template is nearly identical to the `edit` template. Let's create `app/assets/javascripts/templates/users/form.hbs`

```handlebars
<h1>{{headerTitle}} {{fullName}}</h1>
<form>
  <fieldset>
    <div>
      <label {{bindAttr for="firstNameField.elementId"}}>First Name</label>
      {{view Ember.TextField valueBinding='firstName' name='first_name' viewName='firstNameField'}}
    </div>
    <div>
      <label {{bindAttr for='lastNameField.elementId'}}>Last Name</label>
      {{view Ember.TextField valueBinding='lastName' name='last_name' viewName='lastNameField'}}
    </div>
    <div>
      <label {{bindAttr for='quoteField.elementId'}}>Quote</label>
      {{view Ember.TextArea valueBinding='quote' name='quote' viewName='quoteField'}}
    </div>
    <a href='#' {{action save}} class='btn btn-success'>{{buttonTitle}}</a>
  </fieldset>
</form>
<div class='page-header'></div>

<a href='#' {{action cancel target='controller'}} class='btn btn-inverse'>Cancel</a>
```

And in both the `new` and `edit` template remove the markup and replace with

```handlebars
{{ template 'users/form' }}
```

Now we need to edit the two controllers. In `App.UsersNewController` add to the two attributes:

```coffeescript
headerTitle: 'Create'
buttonTitle: 'Create'
```

And likewise in `App.UsersEditController`:

```coffeescript
headerTitle: 'Edit'
buttonTitle: 'Update'
```

Last part for this section is to add the `update` action to `app/controllers/users_controller.rb`:

```ruby
def update
  user = User.find(params[:id])
  if user.update_attributes(params[:user])
    render json: user
  else
    render json: user, status: 422
  end
end
```

Now go through and everything should work! This allows us to treat the templates similar to a partial in Rails.

Finally we're going to add the ability to delete records. Because this is an action we are going to limit to the `edit` page we will put the link below the `render` call

```handlebars
<a href='#' {{action 'destroy'}} class='btn btn-danger'>Destroy</a>
```

Now we add the action to the `App.UsersEditController`

```coffeescript
destroy: ->
  @content.deleteRecord()
  @store.commit()
  @transitionToRoute 'users.index'
```

And we add the `destroy` action to the backend

```ruby
def destroy
  user = User.find(params[:id])
  if user.destroy
    render json: user, status: 204
  else
    render json: user
  end
end
```

The `204` status here is refers to `No Content`. Ember-data expects this to ensure the destroy action is a success.

That's it! You've just created your very first Ember app with all of the CRUD actions. Congratulations!
