Request = require '../components/request'

module.exports = (app, fn) ->
  sundae = require '../sundae'
  sundae.Request = fn?(Request) or Request
