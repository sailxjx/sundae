# Javascript do not support multiple inheritance, so just feel free to use mixins
_ = require 'lodash'
util = require './util'

ensure = require './decorators/ensure'
beforeAction = require './decorators/before'
afterAction = require './decorators/after'
select = require './decorators/select'

_mix = (base, target) ->
  ignores = ['__super__', 'constructor']
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

_insertCallbacks = (fn, props = []) ->
  props = Array.prototype.slice.call(props, 0) if toString.call(props) is '[object Arguments]'
  @_beforeActions = if @_beforeActions then _.clone(@_beforeActions) else []
  @_afterActions = if @_afterActions then _.clone(@_afterActions) else []
  options = if toString.call(props[props.length - 1]) is '[object Object]' then props.pop() else {}

  {only, except, parallel} = _normalizeOptions(options)
  _fn = fn.apply(this, props)

  # @param: {Object} req
  # @param: {Object} res
  # @param: {Object} result [optional]
  # @param: {Function} callback
  _applyCallback = (args...) ->
    [req, res] = args
    next = args.pop()
    {action} = req

    if (not _.isEmpty(only) and action not in only) or (not _.isEmpty(except) and action in except)
      # Skip by only/except options
      next(null, args[2] or {})
    else
      if parallel
        # Parallel execute function without callback
        _fn.apply this, args
        # Then skip and use the origin result
        next(null, args[2] or {})
      else
        _fn.apply this, arguments

  @_beforeActions.push _applyCallback if fn.before
  @_afterActions.push _applyCallback if fn.after

class BaseController

  # Mixin methods from other modules
  @mixin: (args...) -> _mixin this, args

  # Ensure declared params
  @ensure: -> _insertCallbacks.call this, ensure, arguments

  # Function hook before action
  @before: -> _insertCallbacks.call this, beforeAction, arguments

  # Function hook after action
  @after: -> _insertCallbacks.call this, afterAction, arguments

  # Select properties before response
  @select: -> _insertCallbacks.call this, select, arguments

module.exports = BaseController
