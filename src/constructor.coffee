path = require 'path'

module.exports = (app) ->

  controllers = {}

  _controllerPath = null

  app.registerController = (name, controller) ->
    if arguments.length is 1
      controller = name
      name or= controller.name or controller.constructor.name

    unless toString.call(name) is '[object String]'
      throw new Error "Controller has a invalid name"

    name = name.toLowerCase()
    # Remove the controller suffix
    name = name[...-10] if name[-10..] is 'controller'

    controllers[name] = controller

  app.setControllerPath = (controllerPath) -> _controllerPath = controllerPath

  app.getController = (name) ->
    unless controllers[name]
      # Load controller when set the controller path
      throw new Error("Controller path is not settled") unless _controllerPath
      controllers[name] = require path.join(_controllerPath, name)
    controllers[name]

