# Hooks after action excuted

async = require 'async'
util = require '../util'

after = (list) ->
  list = util._toArray list

  return (req, res, result, callback) ->
    {_ctrl} = req
    parallel = if toString.call(callback) is '[object Function]' then false else true

    if parallel  # No callback
      list.forEach (method) ->
        fn = _ctrl[method]
        return false unless toString.call(fn) is '[object Function]'
        fn.call _ctrl, req, res, result
    else
      async.reduce list, result, (result, method, next) ->
        fn = _ctrl[method]
        return next(null, result) unless toString.call(fn) is '[object Function]'
        if fn.length is 4
          fn.call _ctrl, req, res, result, (err, _result) -> next err, _result or result
        else
          fn.call _ctrl, req, result, (err, _result) -> next err, _result or result
      , callback

after.after = true

module.exports = after
