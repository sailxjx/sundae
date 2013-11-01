{exec} = require('child_process')
should = require('should')
web = require('./service/web')

describe 'web#html', ->
  before (done) ->
    web.run({}, done)

  it 'should get ok on homepage', (done) ->
    exec 'curl http://localhost:3011', (err, stdout) ->
      return done(err) if err?
      text = stdout.trim()
      text.should.eql('Cannot GET /')
      done()

  after (done) ->
    web.die(done)