# A clone version of user controller
class GuestController

  readOne: (req, res, callback) ->
    callback null, name: 'Bran'

  create: (req, res, callback) ->
    # Do something create
    callback null, name: 'Bran'

module.exports = new GuestController
