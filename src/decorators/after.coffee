# Hooks after action excuted

async = require 'async'
util = require '../util'

assembler = (req, res, list, result = {}, callback = ->) ->
  list = util._toArray list

  return (req, res, result, callback) ->
    {_ctrl} = req
    async.reduce list, result, (result, method, next) ->
      fn = _ctrl[method]
      return next() unless toString.call(fn) is '[object Function]'
      if fn.length is 4
        fn.call _ctrl, req, res, result, (err, _result) -> next err, _result or result
      else
        fn.call _ctrl, req, result, (err, _result) -> next err, _result or result
    , callback

assembler.after = true

module.exports = assembler
