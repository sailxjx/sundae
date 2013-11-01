process.on 'message', (msg) ->
  sundae = require('../../index')
  options = JSON.parse(msg) or {}
  sundae.init(options).run ->
    process.send('ready')