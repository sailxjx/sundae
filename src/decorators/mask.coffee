# Mask decorator filter the mask fields
jsonMask = require 'json-mask'

# Convert mongoose object to pure JSON
toObject = (obj) -> return if obj.toObject then obj.toObject() else obj

module.exports = mask = (fields, options = {}) ->

  options.hookFunc =  (req, res, result, callback = ->) ->

    try
      _result = jsonMask toObject(result), fields
    catch err

    callback err, _result

  @postHook options
