should = require 'should'
express = require 'express'
supertest = require 'supertest'
router = require '../lib/router'
request = require '../lib/request'
response = require '../lib/response'
sundae = require '../lib/sundae'

describe 'Router', ->

  app = express()

  request.config app

  response.config app

  router = new router.Router

  router.app = app

  router.callback = (req, res) -> res.json res.result

  # Tell sundae where to load the application
  sundae.set 'mainPath', __dirname

  it 'should register the user resource and initial the routes of user', (done) ->

    router.resource 'user', only: ['read']

    app._router.stack.some (route) ->
      return false unless _route = route?.route
      _route.path is '/users'
    .should.eql true

    supertest(app).get('/users').end (err, res) ->
      res.body.forEach (user) -> user.should.have.properties 'name'
      done err

  it 'should register the user.special function', (done) ->

    router.get '/users/special', to: 'user#special'

    app._router.stack.some (route) ->
      return false unless _route = route?.route
      _route.path is '/users/special' and _route.methods.get is true
    .should.eql true

    supertest(app).get('/users/special').end (err, res) ->
      res.body.ok.should.eql 1
      done err

  it 'should store all routes to a stack', ->

    router._stack.forEach (_stack) ->
      _stack.should.have.properties 'path', 'method', '_ctrl', 'ctrl', 'action'

