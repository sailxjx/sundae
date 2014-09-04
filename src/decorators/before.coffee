# Hooks before action executed

before = (method) ->

  return (req, res, callback = ->) ->
    {_ctrl} = req
    fn = _ctrl[method]
    return callback() unless typeof fn is 'function'
    if fn.length is 3
      fn.call _ctrl, req, res, callback
    else
      fn.call _ctrl, req, callback

module.exports = before
