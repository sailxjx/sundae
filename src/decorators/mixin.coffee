_ignoredActions = [
  '__super__'
  'constructor'
  'super_'
]

_mixin = (actions) ->
  controller = this
  if toString.call(actions) is '[object Array]'
    actions.forEach (_actions) -> _mixin.call controller, _actions
  else if toString.call(actions) is '[object Object]'
    for actionName, fn of actions
      if hasOwnProperty.call(actions, actionName) and actionName not in _ignoredActions
        @action actionName, fn
  else throw new Error("Invalid mixin target")
  return

module.exports = mixin = (actions...) ->
  controller = this
  actions.forEach (_actions) -> _mixin.call controller, _actions

