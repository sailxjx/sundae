sundae
======

Rtf restful framework for node

[![NPM version][npm-image]][npm-url]
[![Build Status][travis-image]][travis-url]
[![Talk topic][talk-image]][talk-url]

# Intro

Sundae is a light weight api framework based on express, but more intesting than express.

# A quick brief of router

```coffeescript
app = sundae express()

# You can definitely declare the path to route
# Router support all methods exported from `methods` module (get/post/put/delete/options/etc...)
# The route pattarn is something like `app[method] path, to: {controller}#{action}`
app.get '/', to: 'home#index'

# Post method
app.post '/', to: 'home#create'

# Resource route
# Then you also got the `resource` function to do the above things more restfully
app.resource 'home', only: ['create', 'read']

# Router options
# Router support some options like
# `only`: Only use actions listed in the only option
# `except`: Omit the actions in except option
# `to`: Alias to `ctrl#action`
# `ctrl`: Controller name
# `action`: Action name
# The example below shows mapping a group of `user` restful apis to the admin controller
app.resource 'user', ctrl: 'admin'
```

# A quick brief of controller

```coffeescript
app = sundae express()

app.controller 'home', ->

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
  @action 'index', (req, res, callback) ->
    callback null,
      welcome: 'Hello World'
      "user-agent": req.get('user-agent')
      useless: 'useless message'

  # This is a filter function looks like controller actions
  # You can call this function from router
  # But most time you shouldn't do this
  @action 'checkAgent', (req, res, callback) ->
    userAgent = req.get('user-agent')
    # If the first param of callback is not null
    # controller.index will not be called
    return callback(new Error('GOD! WHY ARE YOU STILL USING IE?')) if userAgent.match /MSIE/
    callback()
```

# Router options

- `only` only keep the specific actions
- `except` without the specific actions

# Decorator options

- `only` only the specific actions will apply hooks
- `except` all actions will apply hooks without the except actions
- `parallel` hooks will be parallel executed, the default mode is series (execute one by one)

# TODO

# Changelog

## 0.6.0
- Support stand alone application build with sundae
- Set app.request/response to an constructor when using sundae without express
- Add `has` function on request

## 0.5.10
- Add `mask` decorator;

## 0.5.8
- Add `least` decorator.

## 0.5.0
- Apply `sundae` on the application level.
- New router, controller, action patterns.

## 0.4.0
- remove `express` in dependencies, you should require express by yourself in application
- change the initialize functions, for more infomation, check the 'examples' directory
- remove cli mode

## 0.3.6
- use some options in the resource directive, e.g. `ctrl`, `action` ...

## 0.3.3
- fix expand of req.headers, req.cookies etc.

## 0.3.1
- remove wrap of actions, every action will receive three arguments: req, res, callback

## 0.3.0
- hooks do not apply on each action now, they are only bind to actions emit by router
- embed err1st package

## 0.2.7

- ignore lib directory in development mode

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

[talk-url]: https://guest.talk.ai/rooms/afc690a03b
[talk-image]: http://img.shields.io/talk/t/afc690a03b.svg
