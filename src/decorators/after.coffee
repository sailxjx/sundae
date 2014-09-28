# Hooks after action excuted

after = (method) ->

  return (req, res, result, callback = ->) ->
    {ctrlObj} = req
    fn = ctrlObj[method]
    return callback(null, result) unless typeof fn is 'function'
    fn.call ctrlObj, req, res, result, callback

module.exports = after
