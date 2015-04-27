# Ensure declared params
# Or response error messages when miss some param
util = require '../util'

ensure = (ensures) ->
  ensures = util._toArray ensures

  return (req, res, callback = ->) ->
    missings = []
    ensures.forEach (_ensure) -> missings.push(_ensure) unless req.get(_ensure)?
    if missings.length > 0
      err = new Error("Params #{missings.join(', ')} missing")
      err.phrase = 'PARAMS_MISSING'
      err.params = [missings.join(', ')]
      return callback err
    callback(null)

module.exports = ensure
