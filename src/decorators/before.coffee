# Hooks before action executed

async = require 'async'
_ = require 'lodash'
util = require '../util'

before = (list) ->
  list = util._toArray list

  return (req, res, callback) ->
    {_ctrl} = req
    parallel = if toString.call(callback) is '[object Function]' then false else true

    if parallel
      list.forEach (method) ->
        fn = _ctrl[method]
        return false unless toString.call(fn) is '[object Function]'
        fn.call _ctrl, req, res
    else
      async.eachSeries list, (method, next) ->
        fn = _ctrl[method]
        return next() unless toString.call(fn) is '[object Function]'
        if fn.length is 3
          fn.call _ctrl, req, res, next
        else
          fn.call _ctrl, req, next
      , callback

before.before = true

module.exports = before
