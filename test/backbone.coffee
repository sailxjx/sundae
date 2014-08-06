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

  it 'should check for the global decorators and skip the useless ones', (done) ->
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
