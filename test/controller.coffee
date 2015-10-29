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
      @postHook options

    custom = app.controller 'custom', ->

      @guard only: 'readOne'

      @action 'read', (req, res, callback) -> callback null, 'ok'

      @action 'readOne', (req, res, callback) -> callback null, 'ok'

    custom.call 'read', {}, {}, (err, body) -> body.should.eql 'ok'

    custom.call 'readOne', {}, {}, (err) -> err.message.should.eql 'Should not pass'

  it 'should apply the hook on each action when set only to *', ->

    app = sundae express()

    app.decorator 'guard', (options) ->
      options.hookFunc = (req, res, callback) ->
        callback new Error('Should not pass')
      @preHook options

    custom = app.controller 'custom', ->

      @guard only: 'readOne *'

      @action 'read', (req, res, callback) -> callback null, 'ok'

      @action 'readOne', (req, res, callback) -> callback null, 'ok'

    custom.call 'read', {}, {}, (err) -> err.message.should.eql 'Should not pass'

    custom.call 'readOne', {}, {}, (err) -> err.message.should.eql 'Should not pass'

  it 'should not apply excepted hooks (in post hook)', ->

    app = sundae express()

    app.decorator 'guard', (options) ->
      options.hookFunc = (req, res, result, callback) ->
        callback new Error('Should not pass')
      @postHook options

    custom = app.controller 'custom', ->

      @guard except: 'read'

      @action 'read', (req, res, callback) -> callback null, 'ok'

      @action 'readOne', (req, res, callback) -> callback null, 'ok'

    custom.call 'read', {}, {}, (err, body) -> body.should.eql 'ok'

    custom.call 'readOne', {}, {}, (err) -> err.message.should.eql 'Should not pass'

  it 'should test for the parallel option', (done) ->

    app = sundae express()

    sleeped = false

    app.decorator 'sleep', (options) ->
      options.hookFunc = (req, res, result, callback) ->
        setTimeout ->
          sleeped = true
        , 20

      @postHook options

    custom = app.controller 'custom', ->

      @sleep parallel: true

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
      @preHook hookFunc: @action 'incr'

      @preHook hookFunc: @action 'incr'

    custom.call 'read', {}, {}, (err, calledNum) -> calledNum.should.eql 1

  it 'should apply the hooks in current order', ->

    app = sundae express()

    appliedHooks = ''

    custom = app.controller 'custom', ->

      @preHook hookFunc: (req, res, callback) -> callback null, appliedHooks += '1'

      @preHook hookFunc: (req, res, callback) -> callback null, appliedHooks += '2'

      @postHook hookFunc: (req, res, result, callback) -> callback null, appliedHooks += '4'

      @postHook hookFunc: (req, res, result, callback) -> callback null, appliedHooks += '5'

      @action 'read', (req, res, callback) -> callback null, appliedHooks += '3'

    custom.call 'read', {}, {}, (err, result) -> result.should.eql '12345'
