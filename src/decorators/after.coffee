# Hooks after action excuted

module.exports = after = (postActionName, options = {}) ->

  controller = this

  if toString.call(postActionName) is '[object Function]'
    options.hookFunc = postActionName

  else if toString.call(postActionName) is '[object String]'
    options.hookFunc = (req, res, result, callback) ->
      actionFunc = controller.action postActionName
      unless toString.call(actionFunc) is '[object Function]'
        throw new Error "Action #{postActionName} is not exist"
      actionFunc.call controller._actions, req, res, result, callback
    options.hookName = postActionName

  else
    throw new Error "Invalid post action name"

  @_postHook options
