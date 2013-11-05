{exec} = require('child_process')
should = require('should')
webMaster = require('./web-master')

describe 'web#html', ->
  before (done) ->
    webMaster.run('html', done)

  it 'should get ok on homepage', (done) ->
    exec 'curl http://localhost:3011', (err, stdout) ->
      return done(err) if err?
      text = stdout.trim()
      text.should.eql('ok')
      done()

  after (done) ->
    webMaster.die(done)