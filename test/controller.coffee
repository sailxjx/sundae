should = require 'should'
express = require 'express'
async = require 'async'
supertest = require 'supertest'

BaseController = require '../lib/controller'
backbone = require '../lib/backbone'

describe 'Controller', ->

  it 'should mix methods from other instance by mixin function', ->

    class Mixin1

      foo1: ->

      @bar1: 'bar1'

    class Mixin2

      foo2: ->

      @bar2: 'bar2'

    class Custom extends BaseController

      @mixin Mixin1, Mixin2

    custom = new Custom
    Custom.should.have.properties 'bar1', 'bar2'
    custom.should.have.properties 'foo1', 'foo2'

  # Test for controller options
  it 'should test for the only/except option', (done) ->
    app = express()

    class Custom extends BaseController

      @ensure '_userId', only: 'readOne'

      read: (req, callback) -> callback null, ok: 1

      readOne: (req, callback) -> callback null, ok: 1

    app.use (req, res, next) ->
      req._ctrl = new Custom
      req.action = req.path[1..]
      backbone req, res, (req, res) ->
        res.json res.err or res.result

    async.parallel [
      (next) ->
        supertest app
          .get '/read'
          .end (err, res) ->
            should(res.body.ok).eql 1
            next err
      (next) ->
        supertest app
          .get '/readOne'
          .end (err, res) ->
            should(res.body.ok).eql null
            next err
    ], done

  it 'should test for the parallel option', (done) ->

    app = express()

    sleeped = false

    class Custom extends BaseController

      @after 'sleep20ms', parallel: true

      read: (req, callback) -> callback null, ok: 1

      sleep20ms: (req, res) ->
        setTimeout ->
          sleeped = true
        , 20

    app.use (req, res, next) ->
      req._ctrl = new Custom
      req.action = 'read'
      backbone req, res, (req, res) -> res.json ok: 1

    supertest app
      .get '/read'
      .end (err, res) ->
        # AfterAction not executed
        sleeped.should.eql false
        # Wait 30ms
        setTimeout ->
          sleeped.should.eql true
          done()
        , 30

  it 'should test for the transfer option', (done) ->

    app = express()

    class Custom extends BaseController

      @after 'showMessage', transfer: (message) -> message.content = 'hi'

      read: (req, callback) -> callback null, content: 'hello'

      showMessage: (req, res, message, next) -> next null, message

    app.use (req, res, next) ->
      req._ctrl = new Custom
      req.action = 'read'
      backbone req, res, (req, res) ->
        res.result.content.should.eql 'hi'
        res.json ok: 1

    supertest app
      .get '/read'
      .end done

