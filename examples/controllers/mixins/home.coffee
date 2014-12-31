class HomeMixin

  changeName: (req, res, result, callback) ->
    result.welcome = 'Hello Sundae'
    callback null, result

module.exports = HomeMixin
