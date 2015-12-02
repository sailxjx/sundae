# Build a sub application with the benefits of sundae

should = require 'should'
sundae = require '../src/sundae'

describe 'Subapp', ->

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
      req = app.request.derive()
      req.set key, val, true for key, val of params

      res = app.response.derive()
      app.controller('rpc').call 'foo', req, res, callback

    # Test user function
    params = accepted: 'accepted', discarded: 'discarded'

    foo params, (err, result) ->
      result.should.eql accepted: 'accepted'
      done err
