should = require 'should'
express = require 'express'
supertest = require 'supertest'
Router = require '../src/router'
request = require '../src/request'
response = require '../src/response'
sundae = require '../src/sundae'

describe 'Router', ->

  app = express()

  request app

  response app

  router = Router app

  router.ctrlDir = __dirname + '/controllers'

  router.callback = (req, res) -> res.json res.result

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

  it 'should use the applied controller in the newuser route', (done) ->
    router.resource 'newuser', ctrl: 'guest'
    supertest(app).get('/newusers/1').end (err, res) ->
      res.body.name.should.eql 'Bran'
      done err

  it 'should store all routes to a stack', ->

    router._stack.forEach (_stack) ->
      _stack.should.have.properties 'path', 'method', 'ctrlObj', 'ctrl', 'action'

