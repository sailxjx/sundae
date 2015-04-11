express = require 'express'
sundae = require '../src/sundae'

app = sundae express()

app.get '/', (req, res) -> res.send 'ok'

app.listen 3333

module.exports = app
