# Ensure declared params
# Or response error messages when miss some param
Err = require 'err1st'

ensure = (req, res, ensures, callback) ->
  ensures = ensures.split ' ' if typeof ensures is 'string'
  return callback(null) unless ensures instanceof Array

  missings = []

  ensures.forEach (_ensure) -> missings.push(_ensure) unless req.get(_ensure)?

  if missings.length > 0
    return callback(new Err('MISSING_PARAMS', missings))

  callback(null)

ensure.before = true
ensure.key = 'ensure'
ensure.parallel = false

module.exports = ensure
