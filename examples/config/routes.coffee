module.exports = (router) ->

  # You can definitely declare the path to route
  # Router support get/post/put/delete/options methods
  # The route pattarn is something like `router.{method} path, to: {controller}#{action}`
  router.get '/', to: 'home#index'

  # # Post method
  # router.post '/', to: 'home#create'

  # # Put method
  # router.put '/:_id', to: 'home#update'

  # # Delete method
  # router.delete '/:_id', to: 'home#delete'

  # # Resource
  # # Then you also got the `resource` function to do the above things more restfully
  # router.resource 'home'
