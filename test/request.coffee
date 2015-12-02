should = require 'should'
express = require 'express'
supertest = require 'supertest'
sundae = require '../src/sundae'

describe 'Sundae#Request', ->

  it 'should apply the alias/validators/setters when call set method', ->

    app = sundae express()

    app.request.importKeys = ['_id']
    app.request.allowedKeys = ['_id', 'name', 'email', 'location', 'fullname']
    app.request.alias = address: 'location'
    app.request.validators = fullname: (fullname) -> fullname.length < 10
    app.request.setters = email: (email) -> "user" + email

    req = {}
    req.__proto__ = app.request
    # Test importKeys
    req.set '_id', 1
    req._id.should.eql 1

    # Test allowdKeys
    req.set 'name', 'Grace'
    req.set 'nickname', 'GG', true
    req.get().should.have.properties 'name'
    req.get().should.not.have.properties 'nickname'

    # Test alias
    req.set 'address', 'Shanghai'
    req.get('location').should.eql 'Shanghai'

    # Test validators
    try
      req.set 'fullname', 'Brfxxccxxmnpcccclllmmnprxvclmnckssqlbb1111b'
    catch err
      err.message.should.eql 'Param fullname is invalid'

    req.get().should.not.have.properties 'fullname'

    # Test setters
    req.set 'email', 'grace@gmail.com'
    req.get('email').should.eql 'usergrace@gmail.com'

    # Test remove
    req.remove '_id'
    should(req._id).eql undefined
    should(req.get('_id')).eql undefined

  it 'should not share _params among all the request instances', (done) ->
    app = sundae express()
    app.request.allowedKeys = ['a', 'b']

    app.controller 'custom', ->

      @action '1', (req, res) ->
        req.get().should.eql a: 'a'
        res.end 'ok'

      @action '2', (req, res) ->
        req.get().should.eql b: 'b'
        res.end 'ok'

    app.get '/1', to: 'custom#1'
    app.get '/2', to: 'custom#2'

    supertest(app).get('/1?a=a').end (err, res) ->
      res.text.should.eql 'ok'
      supertest(app).get('/2?b=b').end (err, res) ->
        res.text.should.eql 'ok'
        done err
