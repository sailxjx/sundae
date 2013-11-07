routes = ->
  # Set response content type
  @application = 'json'

  # Set homepage
  @root('home', {application: 'html'})

  @resource('user')

  @get('/500', {to: '500'})

  @http404()

  @http500()

module.exports = routes