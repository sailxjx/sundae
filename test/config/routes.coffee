path = require 'path'

module.exports = (router) ->

  router.ctrlDir = path.join __dirname, '../controllers'

  router.resource 'user'
