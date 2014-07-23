should = require 'should'
express = require 'express'
Request = require '../lib/request'
request = require 'supertest'

describe 'Request', ->

  it 'should extend the express request object', (done) ->
    app = express()

    app.use (req, res) ->
      _req = new Request req
      _req.should.have.properties 'headers', 'params', 'query'
      res.end('ok')

    request(app).get('/').end(done)
