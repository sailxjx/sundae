should = require 'should'
express = require 'express'
supertest = require 'supertest'

request = require '../lib/request'
response = require '../lib/response'
configer = require '../lib/configer'

describe 'Configer#Request', ->

  app = express()

  it 'should modify the properties of Request object', (done) ->

    configer.request app, (req) -> req.allowedKeys = ["name"]

    app.use (req, res) ->
      req.set 'name', 'Grace'
      req.set 'email', 'grace@gmail.com'
      req.get('name').should.eql 'Grace'
      should(req.get('email')).eql null
      res.end 'ok'

    supertest(app).get('/').end(done)

  it 'should modify the properties of Response object', ->

    configer.response app, (res) ->
      # Do nothing
