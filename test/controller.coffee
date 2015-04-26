should = require 'should'
express = require 'express'
supertest = require 'supertest'
sundae = require '../src/sundae'

describe 'Controller', ->

  app = sundae express()

  it 'should mix methods from other instance by mixin function', ->

    class Mixin1

      foo1: ->

      @bar1: 'bar1'

    class Mixin2

      foo2: ->

      @bar2: 'bar2'

    class CustomController

      custom: ->

    custom = app.registerController 'custom', ->
      @mixin Mixin1, Mixin2
      new CustomController

    custom.constructor.should.have.properties 'bar1', 'bar2'
    custom.should.have.properties 'foo1', 'foo2', 'custom'

  # # Test for controller options
  # it 'should test for the only/except option', (done) ->
  #   app = express()

  #   class Custom extends BaseController

  #     @ensure '_userId', only: 'readOne'

  #     read: (req, res, callback) -> callback null, ok: 1

  #     readOne: (req, res, callback) -> callback null, ok: 1

  #   app.use (req, res, next) ->
  #     req.ctrlObj = new Custom
  #     req.action = req.path[1..]

  #     incubator req.ctrlObj, req.action

  #     backbone req, res, (req, res) ->
  #       res.json res.err or res.result

  #   async.parallel [
  #     (next) ->
  #       supertest app
  #         .get '/read'
  #         .end (err, res) ->
  #           should(res.body.ok).eql 1
  #           next err
  #     (next) ->
  #       supertest app
  #         .get '/readOne'
  #         .end (err, res) ->
  #           should(res.body.ok).eql undefined
  #           next err
  #   ], done

  # it 'should test for the parallel option', (done) ->

  #   app = express()

  #   sleeped = false

  #   class Custom extends BaseController

  #     @after 'sleep20ms', parallel: true

  #     read: (req, res, callback) -> callback null, ok: 1

  #     sleep20ms: (req, res) ->
  #       setTimeout ->
  #         sleeped = true
  #       , 20

  #   app.use (req, res, next) ->
  #     req.ctrlObj = new Custom
  #     req.action = 'read'

  #     incubator req.ctrlObj, req.action

  #     backbone req, res, (req, res) -> res.json res.result

  #   supertest app
  #     .get '/read'
  #     .end (err, res) ->
  #       # AfterAction not executed
  #       sleeped.should.eql false
  #       # Wait 30ms
  #       setTimeout ->
  #         sleeped.should.eql true
  #         done()
  #       , 30
