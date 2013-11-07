routes = ->
  # Set response content type
  @resType = 'html'

  # Set homepage
  @root('home')

  @resource('user')

  @get('/500', {to: '500'})

  @http404()

  @http500()

module.exports = routes