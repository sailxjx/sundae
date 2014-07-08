module.exports = (Request) ->
  class _Request extends Request
    allowedKeys: ['name']
    alias: {}
    validator: {}
