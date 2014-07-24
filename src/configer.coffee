router = require './router'
request = require './request'
response = require './response'
express = require './express'

module.exports =
  routes: router.configer
  express: express.configer
  request: request.configer
  response: response.configer
