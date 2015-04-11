express = require 'express'

app = express()

app.get '/', (req, res) -> res.end('ok')

app.listen 3333

module.exports = app
