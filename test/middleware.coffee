should = require 'should'
ensure = require '../lib/middlewares/ensure'
filter = require '../lib/middlewares/filter'
select = require '../lib/middlewares/select'
Request = require '../lib/request'
Response = require '../lib/response'
configer = require '../lib/configer'

describe 'Middlewares#Ensure', ->

  before -> Request.allowedKeys = ['name', 'lang']

  it 'should callback error when params not meet ensures', ->
    req = new Request params: name: 'hi'
    res = new Response
    ensure req, res, 'name _sessionUserId', (err) -> should(err).not.eql null

  it 'should not callback error when meet all params', ->
    req = new Request params: name: 'hi', lang: 'en'
    res = new Response
    ensure req, res, 'name lang', (err) -> should(err).eql null

  after -> Request.allowedKeys = []

describe 'Middleware#Filter', ->

  before -> Request.allowedKeys = ['name']

  it 'should callback error when use ensureMember filter', ->
    req = new Request params: name: 'Grace'
    res = new Response
    filter.filters =
      upper: (req, res, next) ->
        req.set('name', req.get('name').toUpperCase())
        next()
    filter req, res, 'upper', (err) ->
      req.get('name').should.eql 'GRACE'

  after -> Request.allowedKeys = []

describe 'Middlewares#Select', ->

  it 'should pick fields and ignore others', ->
    result =
      id: '123'
      name: 'Grace'
      updatedAt: '2014-02-24T03:50:00.841Z'
    req = new Request
    res = new Response
    select req, res, 'id updatedAt other', result, (err, result) ->
      result.should.have.keys 'id', 'updatedAt'

  it 'should omit fields', ->
    result =
      name: 'Grace'
      password: '123456'
      updatedAt: '2014-02-24T03:50:00.841Z'
    req = new Request
    res = new Response
    select req, res, '-password', result, (err, result) ->
      result.should.have.keys 'name', 'updatedAt'
