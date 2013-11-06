class ServerError

  index: (args, callback = ->) ->
    callback('error', null)

serverError = new ServerError
module.exports = serverError