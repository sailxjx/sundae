class HomeMixin

  changeName: (req, result, callback) ->
    result.welcome = 'Hello Sundae'
    callback null, result

module.exports = HomeMixin
