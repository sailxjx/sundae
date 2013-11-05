class HomeController

  index: (bundle, callback = ->) ->
    callback(null, 'ok')

homeController = new HomeController
homeController.HomeController = HomeController
module.exports = homeController