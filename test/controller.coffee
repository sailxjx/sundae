should = require 'should'
express = require 'express'
sundae = require '../src/sundae'

describe 'Controller', ->

  it 'should mix methods from other object by mixin function', ->

    app = sundae express()

    Mixin1 = foo1: ->

    Mixin2 = foo2: ->

    custom = app.controller 'custom', ->

      @mixin Mixin1, Mixin2

      @action 'custom', ->

    custom._actions.should.have.properties 'foo1', 'foo2', 'custom'

  it 'should only apply the hook in the only options (in pre hook)', ->

    app = sundae express()

    app.decorator 'guard', (options) ->
      options.hookFunc = (req, res, result, callback) ->
        callback new Error('Should not pass')
      @_postHook options

    custom = app.controller 'custom', ->

      @guard only: 'readOne'

      @action 'read', (req, res, callback) -> callback null, 'ok'

      @action 'readOne', (req, res, callback) -> callback null, 'ok'

    custom.call 'read', {}, {}, (err, body) -> body.should.eql 'ok'

    custom.call 'readOne', {}, {}, (err) -> err.message.should.eql 'Should not pass'

  it 'should not apply excepted hooks (in post hook)', ->

    app = sundae express()

    app.decorator 'guard', (options) ->
      options.hookFunc = (req, res, result, callback) ->
        callback new Error('Should not pass')
      @_postHook options

    custom = app.controller 'custom', ->

      @guard except: 'read'

      @action 'read', (req, res, callback) -> callback null, 'ok'

      @action 'readOne', (req, res, callback) -> callback null, 'ok'

    custom.call 'read', {}, {}, (err, body) -> body.should.eql 'ok'

    custom.call 'readOne', {}, {}, (err) -> err.message.should.eql 'Should not pass'

  it 'should test for the parallel option', (done) ->

    app = sundae express()

    sleeped = false

    app.decorator 'postHook', (options) ->
      options.hookFunc = (req, res, result, callback) ->
        setTimeout ->
          sleeped = true
        , 20

      @_postHook options

    custom = app.controller 'custom', ->

      @postHook parallel: true

      @action 'read', (req, res, callback) -> callback null, 'ok'

    custom.call 'read', {}, {}, (err, body) ->
      body.should.eql 'ok'
      # sleep20ms is not executed
      sleeped.should.eql false
      setTimeout ->
        sleeped.should.eql true
        done()
      , 30

  it 'should not call the hook on the same action more than once', ->

    app = sundae express()

    calledNum = 0

    custom = app.controller 'custom', ->

      @action 'incr', (req, res, callback) ->
        calledNum += 1
        callback()

      @action 'read', (req, res, callback) -> callback null, calledNum

      # Register two incr hook
      @_preHook hookFunc: @action 'incr'

      @_preHook hookFunc: @action 'incr'

    custom.call 'read', {}, {}, (err, calledNum) -> calledNum.should.eql 1
