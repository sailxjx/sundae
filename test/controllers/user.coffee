# Demo user controller for testing
sundae = require '../../lib/sundae'

class UserController extends sundae.BaseController

  read: (req, callback) ->
    callback null, [{name: 'Grace'}, {name: 'Alice'}]

  readOne: (req, callback) ->
    callback null, name: 'Grace'

  create: (req, callback) ->
    # Do something create
    callback null, name: 'Grace'

  # This is a special function
  # You should specific define the route in router file
  special: (req, callback) ->
    callback null, ok: 1

module.exports = new UserController
