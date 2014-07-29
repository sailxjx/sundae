# Application controller is the base controller in the application level
# You can derectly extend you home controller to sundae.BaseController
# But an application controller is still recommended to rule your custom controllers
ApplicationController = require './application'

# Demo home controller
class HomeController extends ApplicationController

  # This is a controller action
  # You can call this function through router
  index: (req, callback) ->
    callback null,
      welcome: 'Hello World'
      "user-agent": req.get('user-agent')
      useless: 'useless message'

  # Request should contain these params
  @::index.ensure = 'user-agent'

  # These filters will execute before controller.index action
  @::index.filters = 'checkAgent'

  # We'll filter the useless key of the callback data
  @::index.select = '-useless'

  # This assembler function is declared in home mixer
  @::index.assemblers = 'changeName'

  # This is a filter function looks like controller actions
  # You can call this function from router
  # But most time you shouldn't do this
  checkAgent: (req, callback) ->
    userAgent = req.get('user-agent')
    # If the first param of callback is not null
    # controller.index will not be called
    return callback(new Error('GOD! WHY ARE YOU STILL USING IE?')) if userAgent.match /MSIE/
    callback()

module.exports = new HomeController
