# Ensure declared params
# Or response error messages when miss some param
try
  Err = require 'err1st'
catch e
  Err = Error
util = require '../util'

ensure = (ensures) ->
  ensures = util._toArray ensures

  return (req, res, callback = ->) ->
    missings = []
    ensures.forEach (_ensure) -> missings.push(_ensure) unless req.get(_ensure)?
    return callback(new Err('MISSING_PARAMS', missings.join(', '))) if missings.length > 0
    callback(null)

module.exports = ensure
