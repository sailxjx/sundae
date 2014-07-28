should = require 'should'
express = require 'express'
supertest = require 'supertest'
backbone = require '../lib/backbone'

describe 'Backbone', ->

  app = express()

  it 'should walk through the application backbone flow', (done) ->
    app.use (req, res, next) ->
      req._ctrl = read: (req, callback) -> callback null, ok: 1
      req.action = 'read'
      backbone req, res, (req, res) -> res.json res.result

    supertest(app).get('/').end (err, res) ->
      res.body.ok.should.eql 1
      done err
