should = require 'should'
express = require 'express'
supertest = require 'supertest'

ensure = require '../lib/decorators/ensure'
filter = require '../lib/decorators/filter'
select = require '../lib/decorators/select'
request = require '../lib/request'
response = require '../lib/response'

describe 'Decorators#Ensure', ->

  app = express()

  before -> request.config app, (req) -> req.allowedKeys = ['name', 'lang']

  it 'should callback error when params not meet ensures', (done) ->
    app.use (req, res) ->
      req.set 'name', 'hi'
      ensure req, res, 'name _sessionUserId', (err) -> should(err).not.eql null
      res.end 'ok'

    supertest(app).get('/').end done

  it 'should not callback error when meet all params', (done) ->
    app.use (req, res) ->
      req.set 'name', 'hi'
      req.set 'lang', 'en'
      ensure req, res, 'name lang', (err) -> should(err).eql null
      res.end 'ok'

    supertest(app).get('/').end done

  after -> request.config app, (req) -> req.allowedKeys = []

describe 'Decorators#Filter', ->

  app = express()

  before -> request.config app, (req) -> req.allowedKeys = ['name']

  it 'should callback error when use ensureMember filter', (done) ->
    app.use (req, res) ->
      req.set 'name', 'Grace'
      req._ctrl =
        upper: (req, res, next) ->
          req.set('name', req.get('name').toUpperCase())
          next()
      filter req, res, 'upper', (err) ->
        req.get('name').should.eql 'GRACE'
      res.end 'ok'

    supertest(app).get('/').end done

  after -> request.config app, (req) -> req.allowedKeys = []

describe 'Decorators#Select', ->

  it 'should pick fields and ignore others', ->
    result =
      id: '123'
      name: 'Grace'
      updatedAt: '2014-02-24T03:50:00.841Z'
    select {}, {}, 'id updatedAt other', result, (err, result) ->
      result.should.have.keys 'id', 'updatedAt'

  it 'should omit fields', ->
    result =
      name: 'Grace'
      password: '123456'
      updatedAt: '2014-02-24T03:50:00.841Z'
    select {}, {}, '-password', result, (err, result) ->
      result.should.have.keys 'name', 'updatedAt'
