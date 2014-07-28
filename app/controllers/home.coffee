ApplicationController = require './application'

class HomeController extends ApplicationController

  index: (req, callback) -> callback null, {welcome: 'Hello World'}

module.exports = new HomeController
