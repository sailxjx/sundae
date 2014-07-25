class HomeController

  index: (req, callback) -> callback null, {welcome: 'Hello World'}

module.exports = new HomeController
