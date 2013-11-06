routes = ->
  # Set response content type
  @resType = 'json'

  # Set homepage
  @root('home')

  @resource('user')

  @get('/500', {to: '500'})

  @http404()

  @http500()

module.exports = routes