# A clone version of user controller
sundae = require '../../src/sundae'

class GuestController extends sundae.BaseController

  readOne: (req, res, callback) ->
    callback null, name: 'Bran'

  create: (req, res, callback) ->
    # Do something create
    callback null, name: 'Bran'

module.exports = new GuestController
