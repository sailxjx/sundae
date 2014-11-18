should = require 'should'
express = require 'express'
supertest = require 'supertest'

ensure = require '../src/decorators/ensure'
beforeAction = require '../src/decorators/before'
select = require '../src/decorators/select'
afterAction = require '../src/decorators/after'
request = require '../src/request'
response = require '../src/response'

describe 'Decorators#Ensure', ->

  app = express()

  before -> request.config app, (req) -> req.allowedKeys = ['name', 'lang']

  it 'should callback error when params not meet ensures', (done) ->
    app.use (req, res) ->
      req.set 'name', 'hi'
      ensure('_sessionUserId') req, res, (err) -> should(err).not.eql null
      res.end 'ok'

    supertest(app).get('/').end done

  it 'should not callback error when meet all params', (done) ->
    app.use (req, res) ->
      req.set 'name', 'hi'
      req.set 'lang', 'en'
      ensure('name') req, res, (err) -> should(err).eql null
      res.end 'ok'

    supertest(app).get('/').end done

  after -> request.config app, (req) -> req.allowedKeys = []

describe 'Decorators#Before', ->

  app = express()

  before -> request.config app, (req) -> req.allowedKeys = ['name']

  it 'should callback error when use ensureMember before hook', (done) ->
    app.use (req, res) ->
      req.set 'name', 'Grace'
      req.ctrlObj =
        upper: (req, res, next) ->
          req.set('name', req.get('name').toUpperCase())
          next()
      beforeAction('upper') req, res, (err) ->
        req.get('name').should.eql 'GRACE'
      res.end 'ok'

    supertest(app).get('/').end done

  after -> request.config app, (req) -> req.allowedKeys = []

describe 'Decorators#After', ->

  it 'should call the after function and get a new property', (done) ->
    app = express()
    app.use (req, res) ->
      req.ctrlObj =
        isNew: (req, res, result, callback) ->
          result.isNew = true
          callback(null, result)
      afterAction('isNew') req, res, {}, (err, result) ->
        result.should.have.properties 'isNew'
      res.end 'ok'
    supertest(app).get('/').end done

describe 'Decorators#Select', ->

  it 'should pick fields and ignore others', ->
    result =
      id: '123'
      name: 'Grace'
      updatedAt: '2014-02-24T03:50:00.841Z'
    select('id updatedAt other') {}, {}, result, (err, result) ->
      result.should.have.keys 'id', 'updatedAt'

  it 'should omit fields', ->
    result =
      name: 'Grace'
      password: '123456'
      updatedAt: '2014-02-24T03:50:00.841Z'
    select('-password') {}, {}, result, (err, result) ->
      result.should.have.keys 'name', 'updatedAt'

  it 'should get the correct fields when the result is an array', ->
    result = ['a', 'b', 'c']
    select('-any') {}, {}, result, (err, result) ->
      result.should.eql ['a', 'b', 'c']
