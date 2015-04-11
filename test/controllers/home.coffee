class HomeController

  index: (req, res, callback) -> res.end 'I am from file'

module.exports = new HomeController
