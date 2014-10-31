# Demo user controller for testing
sundae = require '../../src/sundae'

class UserController extends sundae.BaseController

  read: (req, res, callback) ->
    callback null, [{name: 'Grace'}, {name: 'Alice'}]

  readOne: (req, res, callback) ->
    callback null, name: 'Grace'

  create: (req, res, callback) ->
    # Do something create
    callback null, name: 'Grace'

  # This is a special function
  # You should specific define the route in router file
  special: (req, res, callback) ->
    callback null, ok: 1

module.exports = new UserController
