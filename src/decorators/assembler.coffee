# Assemblers are hooks that will execute after functions
# These assemblers will apply request params, result, and a callback function
# These assemblers will execute one by one

async = require 'async'

toJSON = (obj) -> return if obj.toJSON then obj.toJSON() else obj

assembler = (req, res, list, result = {}, callback = ->) ->
  list = list.split new RegExp(' +') if toString.call(list) is '[object String]'
  return callback(null, result) unless toString.call(list) is '[object Array]'

  {_ctrl} = req

  if toString.call(result) is '[object Array]'
    result = result.map(toJSON)
  else
    result = toJSON(result)

  _assembler = (result, method, next) ->
    fn = _ctrl[method]
    return next() unless typeof fn is 'function'
    if fn.length is 4
      fn.call _ctrl, req, res, result, (err, _result) ->
        next err, _result or result
    else
      fn.call _ctrl, req, result, (err, _result) ->
        next err, _result or result

  async.reduce list, result, (result, method, next) ->
    if toString.call(result) is '[object Array]'
      async.map result, (_result, next) ->
        _assembler _result, method, next
      , next
    else
      _assembler result, method, next
  , callback

assembler.after = true
assembler.key = 'assemblers'
assembler.parallel = false

module.exports = assembler
