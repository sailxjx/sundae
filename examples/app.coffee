# The origin express part
express = require 'express'
app = express()

# Sundae wrapper
sundae = require('../')(app)

# Load sundae modules
sundae.load 'router', require './config/routes'
sundae.load 'request', require './config/request'
sundae.load 'response', require './config/response'

# Use some alias middlewares
app.use sundae.router.http404
app.use sundae.router.http500

app.listen 7000, ->
  console.log '''
    Server started!
    Now visit http://localhost:7000
    To see the welcome message
  '''
