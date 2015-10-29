_ = require 'lodash'
util = require './util'
{slice} = Array.prototype

# Generate an id for each hook or action
_funcId = 0

_normalizeOptions = (options = {}) ->
  {only, except} = options
  options.only = util.toArray only
  options.except = util.toArray except
  options.parallel or= false
  return options

class Controller

  constructor: (@name) ->
    @_actions = {}
    @_preHooks = []
    @_postHooks = []
    @_wrappedActions = {}

  action: (actionName, actionFunc) ->
    if @_actions[actionName] and actionFunc
      throw new Error("Can not redefine action #{actionName}")

    unless @_actions[actionName]
      if toString.call(actionFunc) is '[object Function]'
        actionFunc.funcId or= _funcId += 1
      @_actions[actionName] = actionFunc
    @_actions[actionName]

  actions: (actions = {}) ->
    for actionName, actionFunc of actions
      @action actionName, actionFunc
    return @_actions

  call: (actionName, req, res, callback) ->
    unless @_wrappedActions[actionName]
      @_wrappedActions[actionName] = @_wrapAction actionName
    actions = @_actions
    @_wrappedActions[actionName].apply actions, slice.call arguments, 1

  preHook: (options) ->
    options.hookFunc.funcId or= _funcId += 1
    _options = _.assign {}, options
    @_preHooks.unshift _normalizeOptions _options

  postHook: (options) ->
    options.hookFunc.funcId or= _funcId += 1
    _options = _.assign {}, options
    @_postHooks.push _normalizeOptions _options

  ###*
   * Wrap action with hooks
   * @param  {String} actionName - Name of action
   * @return {Function} actionFunc - Handler of action
  ###
  _wrapAction: (actionName) ->
    actionFunc = @action actionName
    unless toString.call(actionFunc) is '[object Function]'
      throw new Error "Action #{actionName} is not exist"
    return actionFunc unless @_preHooks.length or @_postHooks.length

    actions = @_actions

    _calledFuncIds = []

    _preCheck = (actionFunc, options) ->
      {hookFunc, only, except, parallel, hookName} = options
      return actionFunc if except.length > 0 and actionName in except
      return actionFunc if only.length > 0 and '*' not in only and actionName not in only
      return actionFunc if hookFunc.funcId in _calledFuncIds
      return actionFunc if hookName is actionName

    actionFunc = @_preHooks.reduce (actionFunc, options) ->
      {hookFunc, only, except, parallel} = options
      _actionFunc = _preCheck actionFunc, options
      return _actionFunc if toString.call(_actionFunc) is '[object Function]'

      _actionFunc = (req, res, callback) ->
        if parallel
          hookFunc.call actions, req, res
          actionFunc.call actions, req, res, callback
        else
          hookFunc.call actions, req, res, (err) ->
            return callback(err) if err
            actionFunc.call actions, req, res, callback

      _calledFuncIds.push hookFunc.funcId

      _actionFunc

    , actionFunc

    _calledFuncIds.push actionFunc.funcId

    actionFunc = @_postHooks.reduce (actionFunc, options) ->
      {funcId, hookFunc, only, except, parallel} = options
      _actionFunc = _preCheck actionFunc, options
      return _actionFunc if toString.call(_actionFunc) is '[object Function]'

      _actionFunc = (req, res, callback) ->
        actionFunc.call actions, req, res, (err, result) ->
          return callback(err) if err
          if parallel
            callback err, result
            hookFunc.call actions, req, res, result
          else
            hookFunc.call actions, req, res, result, callback

      _calledFuncIds.push hookFunc.funcId

      _actionFunc

    , actionFunc

module.exports = controller = (app) ->
  _controllers = {}
  app.controller = (ctrlName, ctrlFunc) ->
    unless _controllers[ctrlName]
      _controllers[ctrlName] = new Controller ctrlName
    _.assign _controllers[ctrlName], app._decorators
    ctrlFunc?.apply _controllers[ctrlName], _controllers[ctrlName]
    _controllers[ctrlName]
