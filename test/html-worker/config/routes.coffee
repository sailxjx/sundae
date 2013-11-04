routes = ->
  # Set response content type
  @resType = 'html'

  # Set homepage
  @root('home')

  @resource('user')

  @http404()

module.exports = routes