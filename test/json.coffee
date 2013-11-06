{exec} = require('child_process')
should = require('should')
webMaster = require('./web-master')

curlTest = (uri, eql, callback = ->) ->
  exec "curl http://localhost:3011#{uri}", (err, stdout) ->
    return done(err) if err?
    try
      json = JSON.parse(stdout.trim())
    catch e
      return callback(e)
    json.msg.should.eql(eql.msg)
    json.data.should.eql(eql.data)
    callback()

describe 'web#json', ->
  before (done) ->
    webMaster.run('json', done)

  it 'should get ok on homepage', (done) ->
    curlTest('', {msg: 'Success', data: 'ok'}, done)

  it 'should get UserIndex on /user', (done) ->
    curlTest('/user', {msg: 'Success', data: 'UserIndex'}, done)

  it 'should get 404 on /404', (done) ->
    curlTest('/404', {msg: '404 Not Found', data: {}}, done)

  it 'should get 500 on /500', (done) ->
    curlTest('/500', {msg: 'Unknown Error', data: {}}, done)

  after (done) ->
    webMaster.die(done)