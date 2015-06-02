should = require 'should'
supertest = require 'supertest'
express = require 'express'
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
