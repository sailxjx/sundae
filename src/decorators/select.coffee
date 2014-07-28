# Select decorator filter the select fields
_ = require 'lodash'

select = (req, res, fields, result, callback = ->) ->
  fields = fields.split new RegExp(' +') if toString.call(fields) is '[object String]'
  return callback(null, result) unless toString.call(fields) is '[object Array]'

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
select.key = 'select'
select.parallel = false

module.exports = select
