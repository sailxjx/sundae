module.exports = (app) ->

  {response} = app

  ###*
   * Set response data from controller
   * @param  {Mixed} @_data
   * @return {Response}
  ###
  response.data = (@_data) ->
    this

  ###*
   * Set error object
   * @param  {Error} @_err
   * @return {Response}
  ###
  response.error = (@_err) ->
    this

  response.err = response.error
