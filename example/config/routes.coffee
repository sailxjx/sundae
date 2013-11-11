routes = ->
  # Set response content type
  @application = 'html'

  # Set homepage
  @root('home', {application: 'html'})

  @resource('user')

  @get('/500', {to: '500', application: 'html'})

  @http404()

  @http500()

module.exports = routes