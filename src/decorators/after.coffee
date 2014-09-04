# Hooks after action excuted

after = (method) ->

  return (req, res, result, callback = ->) ->
    {_ctrl} = req
    fn = _ctrl[method]
    return callback(null, result) unless typeof fn is 'function'
    fn.call _ctrl, req, res, result, callback

module.exports = after
