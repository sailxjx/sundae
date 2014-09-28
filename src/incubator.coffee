_ = require 'lodash'

_incubate = (ctrlObj, actionName) ->
  _hooks = ctrlObj.constructor?._hooks or []

  _pre = (actionFn, hook) ->
    {parallel} = hook
    _actionFn = actionFn
    return (req, res, callback) ->
      if parallel
        hook.call ctrlObj, req, res
        _actionFn.call ctrlObj, req, res, callback
      else
        hook.call ctrlObj, req, res, (err) ->
          return callback(err) if err
          _actionFn.call ctrlObj, req, res, callback

  _post = (actionFn, hook) ->
    {parallel} = hook
    _actionFn = actionFn
    return (req, res, callback) ->
      actionFn.call ctrlObj, req, res, (err, result) ->
        return callback(err, result) if err
        if parallel
          hook.call ctrlObj, req, res, result
          callback err, result
        else
          hook.call ctrlObj, req, res, result, callback

  # Prevent missing argument of action
  _wrapAction = (actionFn) ->
    return actionFn if actionFn.length is 3
    _actionFn = actionFn
    return (req, res, callback) -> _actionFn.call ctrlObj, req, callback

  actionFn = _wrapAction ctrlObj[actionName]

  _hooks.forEach (hook) ->
    {only, except, parallel} = hook
    # filter by options
    if (not _.isEmpty(only) and actionName not in only) or (not _.isEmpty(except) and actionName in except)
      return false
    if hook.length is 4
      actionFn = _post(actionFn, hook)
    else
      actionFn = _pre(actionFn, hook)

  ctrlObj[actionName] = actionFn

incubator = (ctrlObj, actionName) ->
  ctrlObj._incubations or= {}
  return false if ctrlObj._incubations[actionName]
  ctrlObj[actionName] = _incubate ctrlObj, actionName
  ctrlObj._incubations[actionName] = 1
  return true

module.exports = incubator
