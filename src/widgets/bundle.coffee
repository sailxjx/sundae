class Bundle

  Mixed = ->

  _checkType = (val, type) ->
    switch type
      when Object, Array, Buffer, Date
        return val instanceof type
      when String
        return typeof val is 'string'
      when Number
        return tyepof val is 'number'
      when Boolean
        return typeof val is 'boolean'
      when Mixed
        return true
      else
        return false

  schema:
    req: Object
    res: Object
    ctrl: String
    func: String
    data: Mixed
    options: Object
    socket: Object

  constructor: (type, weeds) ->
    @attrs = {}
    parseMethod = "parse#{type[0].toUpperCase()}#{type[1..]}"
    if typeof @[parseMethod] is 'function'
      @[parseMethod](weeds)

  parseRest: (weeds) ->

  parseSocket: (weeds) ->

  set: (key, val) ->
    if @schema[key]? and _checkType(val, @schema[key])
      @attrs[key] = val
    return this

  get: (key) ->
    @attrs[key]

  toJSON: ->
    return @attrs

bundle = (type = 'rest', weeds...) ->
  return new Bundle(type, weeds)

module.exports = bundle