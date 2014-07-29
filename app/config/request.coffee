module.exports = (req) ->

  # Keys will import as request properties
  req.importKeys = []

  # Keys allowed in `set` function
  req.allowedKeys = ['user-agent']

  # Alias keys will be converted to the value key
  # e.g. 'user-id' will be set as 'userId' if you set the alias as {'user-id': 'userId'}
  # Keys should be lowercase
  req.alias = {}

  # Validator for each key, value will be dropped if validator returns false
  req.validators = {}

  # Custom setter for specific key
  req.setters = {}
