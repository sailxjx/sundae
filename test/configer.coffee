should = require 'should'
Request = require '../lib/request'
Response = require '../lib/response'
sundae = require '../'

describe 'Configer#Request', ->

  it 'should modify the properties of Request object', ->

    sundae.config 'request', (_Request) ->
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

    sundae.config 'response', (_Response) ->
      # Do nothing
