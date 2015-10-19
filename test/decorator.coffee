should = require 'should'
express = require 'express'
sundae = require '../src/sundae'
ratelimit = require '../src/decorators/ratelimit'

describe 'Decorators#Ensure', ->

  app = sundae express()

  req = app.request

  req.set 'name', 'hi'

  req.set 'lang', 'en'

  custom = app.controller 'custom', ->

    @ensure '_userId', only: 'fail'

    @ensure 'name lang', only: 'succ'

    @action 'fail', (req, res, callback) -> callback null, 'fail'

    @action 'succ', (req, res, callback) -> callback null, 'succ'

  it 'should callback error when params not meet ensures', ->

    custom.call 'fail', req, {}, (err) -> err.message.should.eql 'Params _userId missing'

  it 'should not callback error when meet all params', ->

    custom.call 'succ', req, {}, (err, result) -> result.should.eql 'succ'

describe 'Decorators#Least', ->

  app = sundae express()

  req = app.request

  req.set 'name', 'hi'

  req.set 'lang', 'en'

  custom = app.controller 'custom', ->

    @least 'other things', only: 'fail'

    @least 'name', only: 'succ'

    @action 'fail', (req, res, callback) -> callback null, 'fail'

    @action 'succ', (req, res, callback) -> callback null, 'succ'

  it 'should callback error when at least one params existing in the query', ->

    custom.call 'fail', req, {}, (err) -> err.message.should.eql 'Params other, things missing'

  it 'should callback succ when at least one params existing in the query', ->

    custom.call 'succ', req, {}, (err, result) -> result.should.eql 'succ'

describe 'Decorators#Before', ->

  app = sundae express()

  req = app.request

  req.set 'name', 'xiaolaba'

  custom = app.controller 'custom', ->

    @before 'toUpperCase'

    @action 'toUpperCase', (req, res, callback) -> callback null, req.set('name', req.get('name').toUpperCase())

    @action 'read', (req, res, callback) -> callback null, req.get('name')

  it 'should callback error when use ensureMember before hook', ->

    custom.call 'read', req, {}, (err, result) -> result.should.eql 'XIAOLABA'

describe 'Decorators#After', ->

  app = sundae express()

  req = app.request

  req.set 'name', 'xiaolaba'

  custom = app.controller 'custom', ->

    @after 'toUpperCase'

    @action 'toUpperCase', (req, res, name, callback) -> callback null, name.toUpperCase()

    @action 'read', (req, res, callback) -> callback null, req.get('name')

  it 'should call the after function and get a new property', ->

    custom.call 'read', req, {}, (err, result) -> result.should.eql 'XIAOLABA'

describe 'Decorators#Select', ->

  app = sundae express()

  custom = app.controller 'custom', ->

    @select 'id other', only: 'pick array'

    @select '-password', only: 'omit'

    @action 'pick', (req, res, callback) -> callback null, id: 1, name: 'xiaolaba'

    @action 'omit', (req, res, callback) -> callback null, id: 1, password: '123'

    @action 'array', (req, res, callback) -> callback null, [
      id: 1
      name: 'xiaolaba'
    ,
      id: 2
      name: 'dalaba'
    ]

  it 'should pick fields and ignore others', ->

    custom.call 'pick', {}, {}, (err, result) -> result.should.eql id: 1

  it 'should omit fields', ->

    custom.call 'omit', {}, {}, (err, result) -> result.should.eql id: 1

  it 'should get the correct fields when the result is an array', ->

    custom.call 'array', {}, {}, (err, result) -> result.should.eql [
      id: 1
    ,
      id: 2
    ]

describe 'Decorators#Ratelimit', ->

  it 'should check for the limit formats', ->
    ratelimit.parseLimit(1).should.eql 60: 1
    ratelimit.parseLimit('10 20 30').should.eql 60: 10, 600: 20, 3600: 30
    ratelimit.parseLimit('10,20 20').should.eql 20: 10, 600: 20

  it 'should throw out an error when rate limit exceeded', ->

    app = sundae express()

    custom = app.controller 'custom', ->

      @ratelimit 1

      @action 'get', (req, res, callback) -> callback null, ok: 1

      @action 'other', (req, res, callback) -> callback null, ok: 1

    req = ip: '127.0.0.1'
    req.ctrl = 'custom'
    req.action = 'get'
    custom.call 'get', req, {}, (err, result) -> result.ok.should.eql 1

    custom.call 'get', req, {}, (err, result) -> err.phrase.should.eql 'RATE_LIMIT_EXCEEDED'

    # Will not hurt other actions
    req.ctrl = 'custom'
    req.action = 'other'
    custom.call 'other', req, {}, (err, result) -> result.ok.should.eql 1

describe 'Decorators#Mask', ->

  it 'should filter the masked fields', ->

    app = sundae express()

    custom = app.controller 'custom', ->

      @mask 'a,b/d'

      @action 'mask', (req, res, callback) -> callback null,
        a: 'a'
        b:
          c: 'c'
          d: 'd'
        e: 'e'

    req = ctrl: 'custom', action: 'mask'

    custom.call 'mask', req, {}, (err, result) -> result.should.eql a: 'a', b: d: 'd'
