# Build a sub application with the benefits of sundae

should = require 'should'
sundae = require '../src/sundae'

describe 'Subapp', ->

  it '
  should construct new req/res objects when calling new on app.request/response
  \n\t and should not share any temporary properties outside of __proto__
  ', ->

    app = sundae()

    req1 = app.request()
    req2 = app.request()

    req1.__proto__.should.eql req2.__proto__
    req1.set 'a', 'a'
    req1.get('a').should.eql 'a'
    should(req2.get('a')).be.empty

    res1 = app.response()
    res2 = app.response()
    res1.__proto__.should.eql res2.__proto__

  it 'should init an new application object with some util functions', (done) ->
    app = sundae()
    app.should.have.properties 'request', 'response', 'controller', 'decorator'

    # Setup allowedKeys of request
    app.request.allowedKeys = ['accepted']

    # Register a rpc controller
    app.controller 'rpc', ->
      @action 'foo', (req, res, callback) -> callback null, req.get()

    # User should implement this part in their codes
    foo = (params, callback) ->
      req = app.request()
      req.set key, val, true for key, val of params

      res = app.response()
      app.controller('rpc').call 'foo', req, res, callback

    # Test user function
    params = accepted: 'accepted', discarded: 'discarded'

    foo params, (err, result) ->
      result.should.eql accepted: 'accepted'
      done err
