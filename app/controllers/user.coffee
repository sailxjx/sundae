class UserController

  readOne: (req, callback) ->
    callback null, name: 'Alice'

module.exports = new UserController
