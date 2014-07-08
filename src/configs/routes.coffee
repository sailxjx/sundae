router = require '../components/router'

module.exports = (app, fn) -> fn? router(app)
