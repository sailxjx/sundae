# Filters are hooks that will execute before functions
# These filters will apply request params and a callback function
# These filters will execute one by one

async = require 'async'
_ = require 'lodash'

filter = (req, res, list, callback) ->
  list = list.split new RegExp(' +') if toString.call(list) is '[object String]'
  return callback null unless toString.call(list) is '[object Array]'

  async.eachSeries list, (method, next) ->
    filter.filters[method](req, res, next)
  , callback

filter.filters = {}
filter.before = true
filter.key = 'filters'
filter.parallel = false

filter.initialize = ->
  sundae = require '../sundae'
  try
    if _.isEmpty(filter.filters)
      filter.filters = require sundae.get('mainPath'), 'middlewares', 'filters'
  catch e

module.exports = filter
