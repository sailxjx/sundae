async = require 'async'

backbone = (req, res, callback) ->

  {_ctrl, action, middlewares} = req
  {_beforeActions, _afterActions} = _ctrl.constructor
  middlewares or= []

  async.waterfall [
    # Load route level middlewares
    (next) ->
      async.eachSeries middlewares, (fn, next) ->
        fn req, res, next
      , next

    # Call before actions
    (next) ->
      async.eachSeries _beforeActions or [], (fn, next) ->
        fn req, res, next
      , next

    # Call controller action
    (next) ->
      if _ctrl[action].length is 3
        _ctrl[action] req, res, next
      else
        _ctrl[action] req, next

    # Call after actions
    (result, next) ->
      async.reduce _afterActions or [], result, (result, fn, next) ->
        fn req, res, result, next
      , next

  ], (err, result) ->
    res.err = err
    res.result = result
    callback req, res

module.exports = backbone
