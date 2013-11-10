routes = ->
  # Set response content type
  @application = 'json'

  # Set homepage
  @root('home', {application: 'text'})

  @resource('user')

  @get('/500', {to: '500', application: 'html'})

  @http404()

  @http500()

module.exports = routes