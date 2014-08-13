sundae
======

Rtf restful framework for node

[![NPM version][npm-image]][npm-url] [![Build Status][travis-image]][travis-url]

# Intro

Sundae is a light weight api framework based on express, but more intesting than express.

# Application structure
```
- app
  - config          Application configs.
                    Include 'request', 'response', 'express', 'routes', etc.
  - controllers     Application controllers
    - mixins        Codes you want to share between controllers.
                    it's something like 'lib' directory,
                    but the purpose is more clear than 'libraries'.
                    Someone (like me) may confused with how to share codes between controllers,
                    usually you can put these codes in `ApplicationController` or other base controllers.
                    But for most of time, `include` is better than `extend`,
                    so I'd like to put these codes in a different path, and `mix` them in.
                    you can mix them in by using the `@mixin` function in the declaration of controller
  - helpers         Just helpers
  - mailers         Codes deal with mails
  - util            Utility static methods
```

# Cli usage
```
  Usage: sundae [options] [command]

  Commands:

    init
       prepare for the application folder


  Options:

    -h, --help  output usage information
```
# A quick brief of router

You can find this file in `app/config/routes`

```coffeescript
module.exports = (router) ->

  # You can definitely declare the path to route
  # Router support get/post/put/delete/options methods
  # The route pattarn is something like `router.{method} path, to: {controller}#{action}`
  router.get '/', to: 'home#index'

  # # Post method
  # router.post '/', to: 'home#create'

  # # Put method
  # router.put '/:_id', to: 'home#update'

  # # Delete method
  # router.delete '/:_id', to: 'home#delete'

  # # Resource
  # # Then you also got the `resource` function to do the above things more restfully
  # router.resource 'home'
```

# A quick brief of controller

You can try this controller in the `app/controllers` directory.

```coffeescript
class HomeController extends sundae.BaseController

  # Mixin permission functions
  @mixin require './mixins/permission'

  # Request should contain these params
  @ensure 'user-agent', only: 'index'

  # These filters will execute before controller.index action
  @before 'checkAgent'

  # We'll filter the useless key of the callback data
  @select '-useless'

  # This assembler function is declared in home mixer
  @after 'changeName'

  # This is a controller action
  # You can call this function through router
  index: (req, callback) ->
    callback null,
      welcome: 'Hello World'
      "user-agent": req.get('user-agent')
      useless: 'useless message'

  # This is a filter function looks like controller actions
  # You can call this function from router
  # But most time you shouldn't do this
  checkAgent: (req, callback) ->
    userAgent = req.get('user-agent')
    # If the first param of callback is not null
    # controller.index will not be called
    return callback(new Error('GOD! WHY ARE YOU STILL USING IE?')) if userAgent.match /MSIE/
    callback()

module.exports = new HomeController
```

# Router options

- `only` only keep the specific actions
- `except` without the specific actions

# Decorator options

- `only` only the specific actions will apply hooks
- `except` all actions will apply hooks without the except actions
- `parallel` hooks will be parallel executed, the default mode is series (execute one by one)
- `transfer` transfer the result into expected format before apply hooks

# TODO

# Changelog

## 0.2.5

- clone _before/_after actions when extends from parent class

## 0.2.2 ~ 0.2.4

- give up using `transfer` option, it's not a good idea, find another way

## 0.2.1

- check invalid params in router
- error support for 404 and 500 response

## 0.2.0

- change the statement of decorators

## 0.1.5

- change router to singleton, add router _stack

## 0.1.4

- fix post decorator bug

## 0.1.3

- add assembler, post decorators
- fix mixer loader

## 0.1.2

- auto load mixers

## 0.1.1

- add more comments in demo controllers
- fix request reset params bug
- fix cli init crash

## 0.1.0
- new beginning of sundae framework

[npm-url]: https://npmjs.org/package/sundae
[npm-image]: http://img.shields.io/npm/v/sundae.svg

[travis-url]: https://travis-ci.org/sailxjx/sundae
[travis-image]: http://img.shields.io/travis/sailxjx/sundae.svg
