should = require 'should'
express = require 'express'
supertest = require 'supertest'
router = require '../lib/router'
sundae = require '../lib/sundae'

describe 'Router', ->

  # Tell sundae where to load the application
  before -> sundae.set 'mainPath', __dirname

  describe 'Router#Resource', ->

    it 'should register the user resource and initial the routes of user', (done) ->

      app = express()

      _router = router(app)

      _router.callback = (req, res) -> res.json res.result

      _router.resource 'user', only: ['read']

      app._router.stack.some (route) ->
        return false unless _route = route?.route
        _route.path is '/users'
      .should.eql true

      supertest(app).get('/users').end (err, res) ->
        res.body.forEach (user) -> user.should.have.properties 'name'
        done err

  describe 'Router#Get', ->

    it 'should register the user.special function', (done) ->

      app = express()

      _router = router(app)

      _router.callback  = (req, res) -> res.json res.result

      _router.get '/users/special', to: 'user#special'

      app._router.stack.some (route) ->
        return false unless _route = route?.route
        _route.path is '/users/special' and _route.methods.get is true
      .should.eql true

      supertest(app).get('/users/special').end (err, res) ->
        res.body.ok.should.eql 1
        done err

