# Ensure declared params
# Or response error messages when missing some param
util = require '../util'

module.exports = ensure = (ensureKeys, options = {}) ->

  ensureKeys = util.toArray ensureKeys

  options.hookFunc = (req, res, callback) ->
    missingKeys = []
    ensureKeys.forEach (ensureKey) -> missingKeys.push(ensureKey) unless req.get(ensureKey)?
    if missingKeys.length > 0
      err = new Error("Params #{missingKeys.join(', ')} missing")
      err.phrase = 'PARAMS_MISSING'
      err.params = missingKeys
      return callback err
    callback null

  @_preHook options
