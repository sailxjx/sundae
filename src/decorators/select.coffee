# Select decorator filter the select fields
_ = require 'lodash'
util = require '../util'

# Convert mongoose object to pure JSON
toJSON = (obj) -> return if obj.toJSON then obj.toJSON() else obj

module.exports = select = (selectKeys, options = {}) ->

  selectKeys = util.toArray selectKeys

  pickKeys = []
  omitKeys = []

  selectKeys.forEach (field) ->
    if field.charAt(0) is '-'
      omitKeys.push field[1..]
    else if field.charAt(0) is '+'
      pickKeys.push field[1..]
    else
      pickKeys.push field

  options.hookFunc =  (req, res, result, callback = ->) ->

    _select = (result) ->
      result = toJSON result
      return result unless toString.call(result) is '[object Object]'
      result = _.pick result, pickKeys if pickKeys.length
      result = _.omit result, omitKeys if omitKeys.length
      return result

    if toString.call(result) is '[object Array]'
      callback null, result.map(_select)
    else if toString.call(result) is '[object Object]'
      callback null, _select(result)
    else
      callback null, result

  @postHook options
