{fork} = require('child_process')

class WebMaster

  constructor: ->
    @isRunning = false

  run: (options = {}, callback = ->) ->
    @die() if @isRunning
    @child = fork("#{__dirname}/web-worker.coffee")
    setTimeout (=>
      @child.send(JSON.stringify(options))
      ), 200
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