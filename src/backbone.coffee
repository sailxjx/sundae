async = require 'async'

backbone = (req, res, callback) ->

  {$ctrl, action, middlewares} = req

  async.waterfall [
    # Load route level middlewares
    (next) ->
      async.eachSeries middlewares, (fn, next) ->
        fn req, res, next
      , next

    # Call controller action
    (next) ->
      if $ctrl[action].length is 3
        $ctrl[action] req, res, next
      else
        $ctrl[action] req, next

  ], (err, result) ->
    res.set 'err', err
    res.set 'result', result
    callback req, res

module.exports = backbone
