constructor = require './constructor'
router = require './router'
request = require './request'

sundae = (app) ->
  constructor app
  router app
  request app
  app

module.exports = sundae
