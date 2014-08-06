# Select decorator filter the select fields
_ = require 'lodash'
util = require '../util'

# Convert mongoose object to pure JSON
toJSON = (obj) -> return if obj.toJSON then obj.toJSON() else obj

select = (fields) ->

  fields = util._toArray fields

  return (req, res, result, callback = ->) ->

    picks = []
    omits = []

    fields.forEach (field) ->
      if field.indexOf('-') is 0
        omits.push field[1..]
      else if field.indexOf('+') is 0
        picks.push field[1..]
      else
        picks.push field

    _select = (result) ->
      result = toJSON result
      result = _.pick result, picks if picks.length
      result = _.omit result, omits if omits.length
      return result

    if toString.call(result) is '[object Array]'
      callback null, result.map(_select)
    else if toString.call(result) is '[object Object]'
      callback null, _select(result)
    else
      callback null, result

select.after = true

module.exports = select
