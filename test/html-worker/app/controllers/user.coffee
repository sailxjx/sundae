class UserController

  index: (bundle, callback) ->
    callback(null, 'UserIndex')

userController = new UserController
userController.UserController = UserController
module.exports = userController