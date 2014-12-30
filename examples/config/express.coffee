path = require 'path'
morgan = require 'morgan'
bodyParser = require 'body-parser'
cookieParser = require 'cookie-parser'

# Setup express middlewares
module.exports = (app) ->

  app.set 'json spaces', 0
  app.use morgan('[:date] :method :url :status :res[content-length] :response-time ms')
  app.use bodyParser.json()
  app.use bodyParser.urlencoded(extended: true)
  app.use cookieParser()
