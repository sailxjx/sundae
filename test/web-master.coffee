{fork} = require('child_process')

class WebMaster

  constructor: ->
    @isRunning = false

  run: (worker, callback = ->) ->
    @die() if @isRunning
    @child = fork("#{__dirname}/#{worker}-worker/index.coffee")
    @child.on 'message', (msg) =>
      if msg is 'ready'
        @isRunning = true
        return callback()
    return this

  die: (callback = ->) ->
    @child.kill()
    @isRunning = false
    callback()

webMaster = new WebMaster
module.exports = webMaster