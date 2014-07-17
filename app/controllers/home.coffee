class HomeController

  index: (req, callback) ->
    callback null, {welcome: 'Hello World'}

  # @::index.ensure = 'hehe'

module.exports = new HomeController
