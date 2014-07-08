class UserController

  readOne: (req, callback) ->
    console.log req.get()
    callback null, name: 'Alice'

module.exports = new UserController
