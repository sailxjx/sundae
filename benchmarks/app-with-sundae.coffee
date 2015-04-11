express = require 'express'
sundae = require '../src/sundae'

app = express()

app.use sundae()

app.get '/', (req, res) -> res.end('ok')

app.listen 3333

module.exports = app
