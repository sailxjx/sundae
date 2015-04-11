router = require './router'

_sundae =
  ###*
   * Get controller instance
   * @param  {String} ctrl - Controller name
   * @return {Object} Controller instance
  ###
  getController: (ctrl) ->

sundae = (app) ->
  app.sundae = {}
  # Wrap app with router
  router app
  app

module.exports = sundae
