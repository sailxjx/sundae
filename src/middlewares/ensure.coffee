Err = require 'err1st'

ensure = (req, res, callback) ->
  {ctrl, action} = req.get()

ensure.before = true

module.exports = ensure
