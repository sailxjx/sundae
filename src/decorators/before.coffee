# Hooks before action executed

before = (method) ->

  return (req, res, callback = ->) ->
    {ctrlObj} = req
    fn = ctrlObj[method]
    return callback() unless typeof fn is 'function'
    if fn.length is 3
      fn.call ctrlObj, req, res, callback
    else
      fn.call ctrlObj, req, callback

module.exports = before
