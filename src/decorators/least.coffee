# Ensure at least one param in the declared fields
#
_ = require 'lodash'
util = require '../util'

module.exports = least = (keys, options = {}) ->

  keys = util.toArray keys

  options.hookFunc = (req, res, callback) ->
    existKeys = _.pick req.get(), keys
    if Object.keys(existKeys).length is 0
      err = new Error("Params #{keys.join(', ')} missing")
      err.phrase = 'PARAMS_MISSING'
      err.params = keys
      return callback err
    callback null

  @preHook options
