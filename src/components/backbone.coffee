config = require '../config'
async = require 'async'
_ = require 'lodash'
assembler = require '../middlewares/assembler'
filter = require '../middlewares/filter'
select = require '../middlewares/select'
ensure = require '../middlewares/ensure'

backbone = ($ctrl, ctrl, action, middlewares, req, res, callback) ->

  async.waterfall [
    # Load request middlewares
    (next) ->
      async.eachSeries middlewares, (fn, _next) ->
        fn(req, res, _next)
      , next

    # Check params and ensure some params exist
    (next) -> ensure $ctrl[action].ensure or $ctrl.ensure, req, next

    # Call filters before controller
    (next) -> filter $ctrl[action].filters or $ctrl.filters, req, next

    # Call controller action
    (next) ->
      if $ctrl[action].length is 3
        $ctrl[action] req, res, next
      else
        $ctrl[action] req, next

    # Call assemblers after controller
    (result, next) ->
      if typeof result is 'function'
        next = result
        result = {}
      assembler $ctrl[action].assemblers or $ctrl.assemblers, req, result, next

    # Call select middleware and pick properties
    (result, next) ->
      if typeof result is 'function'
        next = result
        result = {}
      select $ctrl[action].select or $ctrl.select, req, result, next

  ], (err, result) ->
    res.set('err', err)
    res.set('result', result)
    res.set('socketId', req.get('socketId'))
    return callback(req, res) if err?

    if typeof $ctrl[action].post is 'function'
      $ctrl[action].post(req, res, result)

    callback(req, res)

module.exports = backbone
