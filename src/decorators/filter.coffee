# Filters are hooks that will execute before functions
# These filters will apply request params and a callback function
# These filters will execute one by one

async = require 'async'
_ = require 'lodash'

filter = (req, res, list, callback) ->
  list = list.split new RegExp(' +') if toString.call(list) is '[object String]'
  return callback null unless toString.call(list) is '[object Array]'

  {_ctrl} = req

  async.eachSeries list, (method, next) ->
    fn = _ctrl[method]
    return next() unless typeof fn is 'function'
    if fn.length is 3
      fn.call _ctrl, req, res, next
    else
      fn.call _ctrl, req, next
  , callback

filter.before = true
filter.key = 'filters'
filter.parallel = false

module.exports = filter
