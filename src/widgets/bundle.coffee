class Bundle

  schema:
    cookie: Object
    lang: String
    result: Object

  constructor: (type, weeds) ->
    @attrs = {}
    parseMethod = "parse#{type[0].toUpperCase()}#{type[1..]}"
    if typeof @[parseMethod] is 'function'
      @[parseMethod](weeds)

  parseRest: (weeds) ->
    [@req, @res] = weeds
    @attrs =
      cookie: weeds.req?.cookies

  parseSocket: (weeds) ->

  set: (key, val) ->
    @attrs[key] = val

  get: (key) ->
    @attrs[key]

  toJSON: ->
    return @attrs

  @__defineGetter__ 'args', ->
    return @args

  @__defineGetter__ 'result', ->
    return @attr['result']

bundle = (type = 'rest', weeds...) ->
  return new Bundle(type, weeds)

module.exports = bundle