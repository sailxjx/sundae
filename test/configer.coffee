should = require 'should'
Request = require '../lib/request'
Response = require '../lib/response'
configer = require '../lib/configer'
express = require 'express'
app = express()

describe 'Configer#Request', ->

  it 'should modify the properties of Request object', ->

    configer.request app, (_Request) ->
      # Modify
      _Request.allowedKeys = ["name"]
      # Check
      Request.allowedKeys.should.containEql 'name'
      req = new Request
      req.set 'name', 'Grace'
      req.set 'email', 'grace@gmail.com'
      req.get('name').should.eql 'Grace'
      should(req.get('email')).eql null

  it 'should modify the properties of Response object', ->

    configer.response 'response', (_Response) ->
      # Do nothing
