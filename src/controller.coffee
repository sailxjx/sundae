# Javascript do not support multiple inheritance, so just feel free to use mixins
_ = require 'lodash'
util = require './util'

_mix = (base, target) ->
  ignores = ['__super__', 'constructor']
  base[key] = prop for key, prop of target when hasOwnProperty.call(target, key) and key not in ignores
  return base

_mixin = (child, parent) ->
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
  @_beforeActions = [] unless @_beforeActions
  @_afterActions = [] unless @_afterActions
  options = if toString.call(props[props.length - 1]) is '[object Object]' then props.pop() else {}

  {only, except, parallel} = _normalizeOptions(options)
  _fn = fn(props)

  # @param: {Object} req
  # @param: {Object} res
  # @param: {Object} result [optional]
  # @param: {Function} callback
  _applyCallback = (args...) ->
    next = args.pop()
    req = args[0]
    {action} = req
    result = if toString.call(args[2]) is '[object Function]' then {} else args[2]

    if (not _.isEmpty(only) and action not in only) or (not _.isEmpty(except) and action in except)
      # Skip by only/except options
      next(null, result)
    else if parallel
      # Parallel execute function without callback
      _fn.apply this, args
      # Then skip
      next(null, result)
    else
      _fn.apply this, arguments

  @_beforeActions.push _applyCallback if fn.before
  @_afterActions.push _applyCallback if fn.after

ensure = require './decorators/ensure'
before = require './decorators/before'
after = require './decorators/after'
select = require './decorators/select'

class BaseController

  # Mixin methods from other modules
  @mixin: (args...) -> args.forEach (parent) => _mixin this, parent

  # Ensure declared params
  @ensure: -> _insertCallbacks.call this, ensure, arguments

  # Function hook before action
  @before: -> _insertCallbacks.call this, before, arguments

  # Function hook after action
  @after: -> _insertCallbacks.call this, after, arguments

  # Select properties before response
  @select: -> _insertCallbacks.call this, select, arguments

module.exports = BaseController
