_ = require('lodash')

class CustomError extends Error

  constructor: (@msg = '', @code = null) ->
    super

  toJSON: ->
    return {
      code: @toCode()
      msg: @toMsg()
    }

  toCode: -> Number(@code.toString()[3..])

  toStatus: -> Number(@code.toString()[0..2])

  toMsg: -> @msg


class ErrorHandler

  constructor: ->
    @_codes =
      error: 502900
      succ: 200000
    @_msgs =
      error: 'Unknown Error'
      succ: 'Success'
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

  parse: (err) ->
    if typeof err is 'string' and @msgs[err]?
      $err = new CustomError(@msgs[err], @codes[err])
    else if err instanceof Array
      [flag, args] = err
      if typeof @msgs[flag] is 'function'
        msg = @msgs[flag].apply(this, args)
      else if @msgs[flag]?
        msg = @msgs[flag]
      else
        msg = @msgs.error
      code = @codes[flag] or @codes.error
      return new CustomError(msg, code)
    else if err?
      return new CustomError(err, @codes.error)
    else
      return new CustomError(null, @codes.succ)

$errorHandler = new ErrorHandler
errorHandler = (errors) ->
  $errorHandler.register(errors) if typeof errors if 'function'
  return $errorHandler

module.exports = errorHandler