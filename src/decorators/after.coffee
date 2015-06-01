# Hooks after action excuted

after = (postActionName) ->

  return (req, res, result, callback = ->) ->
    {ctrlObj} = req
    fn = ctrlObj[method]
    return callback(null, result) unless typeof fn is 'function'
    fn.call ctrlObj, req, res, result, callback

module.exports = after = (postActionName, options) ->

  ctrlObj = this

  if toString.call(postActionName) is '[object Function]'
    options.hookFunc = postActionName
  else if toString.call(postActionName) is '[object String]'
    options.hookFunc = (req, res, result, callback) ->
      actionFunc = ctrlObj.action postActionName
      unless toString.call(actionFunc) is '[object Function]'
        throw new Error "Action #{postActionName} is not exist"
      actionFunc.call ctrlObj._actions, req, res, result, callback
  else
    throw new Error "Invalid post action name"

  @_postHook options
