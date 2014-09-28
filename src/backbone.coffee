async = require 'async'

backbone = (req, res, callback) ->

  {ctrlObj, action, middlewares} = req
  middlewares or= []

  async.waterfall [
    # Load route level middlewares
    (next) ->
      async.eachSeries middlewares, (fn, next) ->
        fn req, res, next
      , next

    # Call actions
    (next) ->
      ctrlObj[action] req, res, next

  ], (err, result) ->
    res.err = err
    res.result = result
    callback req, res

module.exports = backbone
