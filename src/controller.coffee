# Javascript do not support multiple inheritance, so just feel free to use mixins
_ = require 'lodash'
util = require './util'

ensure = require './decorators/ensure'
beforeAction = require './decorators/before'
afterAction = require './decorators/after'
select = require './decorators/select'

ignores = ['__super__', 'constructor']

_mix = (base, target) ->
  for key, prop of target
    if hasOwnProperty.call(target, key) and key not in ignores
      base[key] = prop
  return base

_mixin = (child, parent) ->
  if toString.call(parent) is '[object Array]'
    parent.forEach (obj) -> _mixin child, obj
  else
    _mix(child, parent)
    _mix(child.prototype, parent.prototype)
  return child

_normalizeOptions = (options) ->
  {only, except} = options
  options.only = util._toArray only
  options.except = util._toArray except
  options.parallel or= false
  return options

_registerHooks = (fn, props = []) ->
  props = Array.prototype.slice.call(props, 0) if toString.call(props) is '[object Arguments]'

  @_hooks = if @_hooks then _.clone(@_hooks) else []

  options = if toString.call(props[props.length - 1]) is '[object Object]' then props.pop() else {}

  # Bind options to the function
  _fn = fn.apply(this, props)
  _fn = _.extend _fn, _normalizeOptions(options)
  # Hook with four arguments will be treated as a afterAction function
  # Else it will be treated as a beforeAction function
  if _fn.length is 4 then @_hooks.push _fn else @_hooks.unshift _fn
  return true

_bindHooks = (hooks = []) ->

  _this = this

  _pre = (action, hook) ->
    {parallel} = hook
    return (req, res, callback) ->
      if parallel
        hook.call _this, req, res
        action.call _this, req, res, callback
      else
        hook.call _this, req, res, (err) ->
          return callback(err) if err?
          action.call _this, req, res, callback

  _post = (action, hook) ->
    {parallel} = hook
    return (req, res, callback) ->
      action.call _this, req, res, (err, result) ->
        return callback(err, result) if err?
        if parallel
          hook.call _this, req, res, result
          callback err, result
        else
          hook.call _this, req, res, result, callback

  # Prevent missing argument of action
  _wrapAction = (action) ->
    return action if action.length is 3
    return (req, res, callback) -> action.call _this, req, callback

  _applyHooks = (key, action) ->
    return if key in ['constructor'] or typeof action isnt 'function'
    action = _wrapAction(action)
    hooks.forEach (hook) ->
      {only, except, parallel} = hook
      # filter by options
      if (not _.isEmpty(only) and key not in only) or (not _.isEmpty(except) and key in except)
        return false
      if hook.length is 4 then action = _post(action, hook) else action = _pre(action, hook)
    _this[key] = action

  _applyHooks(key, action) for key, action of _this

class BaseController

  constructor: -> _bindHooks.call this, @constructor._hooks

  # Mixin methods from other modules
  @mixin: (args...) -> _mixin this, args

  # Ensure declared params
  @ensure: -> _registerHooks.call this, ensure, arguments

  # Function hook before action
  @before: -> _registerHooks.call this, beforeAction, arguments

  # Function hook after action
  @after: -> _registerHooks.call this, afterAction, arguments

  # Select properties before response
  @select: -> _registerHooks.call this, select, arguments

module.exports = BaseController
