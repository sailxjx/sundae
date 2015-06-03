should = require 'should'
express = require 'express'
sundae = require '../src/sundae'

describe 'Decorators#Ensure', ->

  app = sundae express()

  req = app.request

  req.set 'name', 'hi'

  req.set 'lang', 'en'

  custom = app.controller 'custom', ->

    @ensure '_userId', only: 'fail'

    @ensure 'name lang', only: 'success'

    @action 'fail', (req, res, callback) -> callback null, 'fail'

    @action 'succ', (req, res, callback) -> callback null, 'succ'

  it 'should callback error when params not meet ensures', ->

    custom.call 'fail', req, {}, (err) -> err.message.should.eql 'Params _userId missing'

  it 'should not callback error when meet all params', ->

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
