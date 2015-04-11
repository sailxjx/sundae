should = require 'should'
supertest = require 'supertest'
express = require 'express'
sundae = require '../src/sundae'

describe 'sundae', ->

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

    app.registerController 'home', index: (req, res) -> res.end 'I am from object'

    app.get '/', to: 'home#index'

    supertest(app).get('/').end (err, res) ->
      res.text.should.eql 'I am from object'
      done err

  it 'should auto load the controller when defined controller path', (done) ->

    app = sundae express()

    app.setControllerPath __dirname + '/controllers'

    app.get '/', to: 'home#index'

    supertest(app).get('/').end (err, res) ->
      res.text.should.eql 'I am from file'
      done err
