_ = require('lodash')

class CustomError extends Error

  constructor: (@msg = '', @code = null, @data = {}) ->
    super

  toJSON: ->
    return {
      code: @toCode()
      msg: @toMsg()
      data: @toData()
    }

  toCode: -> Number(@code.toString()[3..])

  toStatus: -> Number(@code.toString()[0..2])

  toMsg: -> @msg

  toData: -> @data

  stringify: -> JSON.stringify(@toJSON())

class ErrorHandler

  constructor: ->
    @_codes =
      succ: 200000
      error: 500900
      '404': 404901
    @_msgs =
      error: 'Unknown Error'
      succ: 'Success'
      '404': '404 Not Found'

    Object.defineProperties this, {
      'codes': {
        get: -> @_codes
        set: (_codes) -> @_codes = _.extend(@_codes, _codes)
      }
      'msgs': {
        get: -> @_msgs
        set: (_msgs) -> @_msgs = _.extend(@_msgs, _msgs)
      }
    }

  register: (errors) ->
    errors.call(this) if typeof errors is 'function'

  parse: (err, data) ->
    if typeof err is 'string' and @msgs[err]?
      msg = if typeof @msgs[err] is 'function' then msg = @msgs[err](data) else @msgs[err]
      $err = new CustomError(msg, @codes[err], data)
    else if err instanceof CustomError
      return err
    else if err?
      return new CustomError(err, @codes.error, data)
    else
      return new CustomError(@msgs.succ, @codes.succ, data)

$errorHandler = new ErrorHandler
errorHandler = (errors) ->
  $errorHandler.register(errors) if typeof errors if 'function'
  return $errorHandler

module.exports = errorHandler