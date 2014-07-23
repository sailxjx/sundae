# Ensure declared params
# Or response error messages when miss some param
Err = require 'err1st'

ensure = (req, res, ensures, callback) ->
  ensures = ensures.split new RegExp(' +') if toString.call(ensures) is '[object String]'
  return callback(null) unless toString.call(ensures) is '[object Array]'

  missings = []
  ensures.forEach (_ensure) -> missings.push(_ensure) unless req.get(_ensure)?
  return callback(new Err('MISSING_PARAMS', missings)) if missings.length > 0

  callback(null)

ensure.before = true
ensure.key = 'ensure'
ensure.parallel = false

module.exports = ensure
