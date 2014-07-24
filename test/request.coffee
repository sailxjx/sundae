should = require 'should'
express = require 'express'
Request = require '../lib/request'
request = require 'supertest'

describe 'Request', ->

  before ->
    Request.importKeys = ['_id']
    Request.allowedKeys = ['_id', 'name', 'email', 'location', 'fullname']
    Request.alias = address: 'location'
    Request.validators = fullname: (fullname) -> fullname.length < 10
    Request.setters = email: (email) -> @email = email

  it 'should extend the express request object', (done) ->
    app = express()

    app.use (req, res) ->
      _req = new Request req
      _req.should.have.properties 'headers', 'params', 'query'
      res.end('ok')

    request(app).get('/').end(done)

  it 'should apply the alias/validators/setters when call set method', ->
    req = new Request

    # Test importKeys
    req.set '_id', 1
    req._id.should.eql 1

    # Test allowdKeys
    req.set 'name', 'Grace'
    req.set 'nickname', 'GG'
    req.get().should.have.properties 'name'
    req.get().should.not.have.properties 'nickname'

    # Test alias
    req.set 'address', 'Shanghai'
    req.get('location').should.eql 'Shanghai'

    # Test validators
    req.set 'fullname', 'Brfxxccxxmnpcccclllmmnprxvclmnckssqlbb1111b'
    req.get().should.not.have.properties 'fullname'

    # Test setters
    req.set 'email', 'grace@gmail.com'
    req.email.should.eql 'grace@gmail.com'

  after ->
    Request.importKeys = []
    Request.allowedKeys = []
    Request.alias = {}
    Request.validators = {}
    Request.setters = {}
