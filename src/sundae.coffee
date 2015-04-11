router = require './router'
constructor = require './constructor'

class Sundae

  constructor: (app) ->
    app.registerController = (name) ->

_sundae =
  ###*
   * Get controller instance
   * @param  {String} ctrl - Controller name
   * @return {Object} Controller instance
  ###
  getController: (ctrl) ->

_sundae = (app) ->

sundae = (app) ->
  constructor app
  # Wrap app with router
  router app
  app

module.exports = sundae
