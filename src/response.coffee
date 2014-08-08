{response} = require 'express'

# Expand express response object
response.config = (app, fn = ->) ->
  response.response = ->
    {err, result} = this
    if err?
      @status(err.status or 400).json err.toJSON?() or message: err.message
    else
      @status(200).json(result)
  fn.call response, response

module.exports = response
