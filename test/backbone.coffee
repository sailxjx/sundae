should = require 'should'
express = require 'express'
supertest = require 'supertest'
async = require 'async'
request = require '../lib/request'
backbone = require '../lib/backbone'
sundae = require '../lib/sundae'

describe 'Backbone', ->

  it 'should walk through the application backbone flow', (done) ->
    app = express()

    app.use (req, res, next) ->
      req._ctrl = read: (req, callback) -> callback null, ok: 1
      req.action = 'read'
      backbone req, res, (req, res) -> res.json res.result

    supertest(app).get('/').end (err, res) ->
      res.body.ok.should.eql 1
      done err

  # Test for controller options
  it 'should test for the only/except option', (done) ->
    app = express()

    class Custom extends sundae.BaseController

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

    class Custom extends sundae.BaseController

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
