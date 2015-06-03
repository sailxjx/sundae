# Hooks before action executed

module.exports = before = (preActionName, options = {}) ->

  controller = this

  if toString.call(preActionName) is '[object Function]'
    options.hookFunc = preActionName

  else if toString.call(preActionName) is '[object String]'
    options.hookFunc = (req, res, callback) ->
      actionFunc = controller.action preActionName
      unless toString.call(actionFunc) is '[object Function]'
        throw new Error "Action #{preActionName} is not exist"
      actionFunc.call controller._actions, req, res, callback
    options.hookName = preActionName

  else
    throw new Error "Invalid post action name"

  @preHook options
