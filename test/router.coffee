path = require 'path'
should = require 'should'
supertest = require 'supertest'
express = require 'express'
jade = require 'jade'
sundae = require '../src/sundae'

describe 'Sundae#Router', ->

  it 'load sundae and register resource function on app', (done) ->

    app = sundae express()

    app.should.have.properties 'resource'

    # The origial app methods should still work
    app.get '/', (req, res) -> res.end 'ok'

    supertest(app).get('/').end (err, res) ->
      res.text.should.eql 'ok'
      done err

  it 'should auto route to the controllers by sundae router', (done) ->

    app = sundae express()

    app.controller 'home', ->
      @action 'index', (req, res) ->
        req.ctrl.should.eql 'home'
        req.action.should.eql 'index'
        res.end 'ok'

    app.get '/', to: 'home#index'

    supertest(app).get('/').end (err, res) ->
      res.text.should.eql 'ok'
      done err

  it 'should register the user resource', (done) ->

    app = sundae express()

    app.controller 'user', ->
      @action 'read', (req, res, callback) ->
        callback null, [{name: 'Xiaolaba'}]

      @action 'readOne', (req, res, callback) ->
        callback null, name: 'Xiaolaba'

      @action 'create', (req, res, callback) ->
        callback null, name: 'Xiaolaba'

    app.resource 'user', only: ['read', 'readOne']

    supertest(app).get('/users').end (err, res) ->
      res.body.forEach (user) -> user.should.have.properties 'name'
      done err

  it 'should use the guest controller in user resource', (done) ->

    app = sundae express()

    app.controller 'guest', ->
      @action 'readOne', (req, res, callback) ->
        callback null, name: 'Bran'

    app.resource 'users', ctrl: 'guest', only: ['readOne']

    supertest(app).get('/users/1').end (err, res) ->
      res.body.name.should.eql 'Bran'
      done err

  it 'should work with routePrefix', (done) ->

    app = sundae express()

    app.controller 'home', ->

      @action 'index', (req, res, callback) -> callback null, path: 'home'

    app.routePrefix = '/v1'

    app.get 'home', to: 'home#index'

    supertest(app).get('/v1/home').end (err, res) ->
      res.body.path.should.eql 'home'
      done err

  it 'should work with routeCallback', (done) ->

    app = sundae express()

    app.controller 'home', ->

      @action 'index', (req, res, callback) -> callback null, path: 'home'

    app.routeCallback = (req, res) ->
      {err, result} = res
      result.path = 'new ' + result.path
      res.status(200).json(result)

    app.get '/home', to: 'home#index'

    supertest(app).get('/home').end (err, res) ->
      res.body.path.should.eql 'new home'
      done err

  it 'handle http 404 route', (done) ->

    app = sundae express()

    app.use (req, res, callback) -> res.status(404).json message: 'Not found'

    supertest(app).get('/').end (err, res) ->
      res.statusCode.should.eql 404
      res.body.message.should.eql 'Not found'
      done()

  it 'handle server error', (done) ->

    app = sundae express()

    app.controller 'home', ->

      @action 'index', (req, res, callback) -> throw new Error('Unknown error')

    app.get '/', to: 'home#index'

    app.use (err, req, res, callback) ->

      res.status(500).json message: err.message

    supertest(app).get('/').end (err, res) ->
      res.statusCode.should.eql 500
      res.body.message.should.eql 'Unknown error'
      done()

  it 'worker with view engine', (done) ->

    app = sundae express()

    app.engine 'jade', jade.__express
    app.set 'views', path.join __dirname, 'views'
    app.set 'view engine', 'jade'

    app.controller 'home', ->

      @action 'index', (req, res, callback) ->
        res.render 'home', title: 'home'

    app.get '/', to: 'home#index'

    supertest(app).get('/').end (err, res) ->
      res.statusCode.should.eql 200
      res.text.should.eql '<h1>home</h1>'
      done err
