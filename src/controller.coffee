_ = require 'lodash'
# util = require './util'

# ensure = require './decorators/ensure'
# beforeAction = require './decorators/before'
# afterAction = require './decorators/after'
# select = require './decorators/select'

# ignores = ['__super__', 'constructor']


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


class Transformer

  trans: ->

module.exports = (fn) ->
  transformer = new Transformer
  controller = fn.apply transformer
  transformer.trans controller

class BaseController

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
