sundae = require '../'

routes = (router) -> router.get '/', to: 'main#index'

express = (app) ->

sundae.config('routes', routes)
  .config('express', express)
  .run ->
    console.log 'App is running on port 3000'
