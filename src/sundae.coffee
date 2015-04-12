methods = require './methods'
router = require './router'
request = require './request'

sundae = (app) ->
  methods app
  router app
  request app
  app

module.exports = sundae
