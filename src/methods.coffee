# Define methods on app object

path = require 'path'

# Transform a normal controller to a superhero
transform = (app) ->

  class Controller

    app: app

  controller = new Controller

  _mixins = []

  # Methods used in the contructor of controller
  decorators =
    mixin: (args...) -> _mixins = _mixins.concat args
    ensure: ->
    before: ->
    after: ->
    select: ->
    # Register action function
    registerAction: (name, action) ->
      controller[name] = action
      _mixins.forEach (_mixin) -> # Do something
    registerActions: (obj) ->
      for name, action of obj
        @registerAction name, action

  _transform = (fn) ->
    obj = fn.apply decorators
    decorators.registerActions(obj) if toString.call(obj) is '[object Object]'

module.exports = (app) ->

  controllers = {}

  controllerPath = null

  app.registerController = (name, controller) ->
    if arguments.length is 1
      controller = name
      name or= controller.name or controller.constructor.name

    unless toString.call(name) is '[object String]'
      throw new Error "Controller has a invalid name"

    name = name.toLowerCase()
    # Remove the controller suffix
    name = name[...-10] if name[-10..] is 'controller'

    if toString.call(controller) is '[object Function]'
      controller = transform(app)(controller)

    controllers[name] = controller

  app.setControllerPath = (_controllerPath) -> controllerPath = _controllerPath

  ###*
   * Get controller instance
   * @param  {String} ctrl - Controller name
   * @return {Object} Controller instance
  ###
  app.getController = (name) ->
    unless controllers[name]
      # Load controller when set the controller path
      throw new Error("Controller path is not settled") unless controllerPath
      app.registerController name, require(path.join(controllerPath, name))
    controllers[name]

  app.callback = (req, res) ->
    {err, data} = res
    throw err if err
    res.send data
