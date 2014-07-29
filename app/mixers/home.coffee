class HomeMixer

  changeName: (req, result, callback) ->
    result.welcome = 'Hello Sundae'
    callback null, result

module.exports = new HomeMixer
