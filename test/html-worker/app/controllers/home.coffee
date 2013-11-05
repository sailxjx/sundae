class HomeController

  index: (bundle, callback = ->) ->
    callback(null, 'hello world')

homeController = new HomeController
homeController.HomeController = HomeController
module.exports = homeController