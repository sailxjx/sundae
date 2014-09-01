should = require 'should'
supertest = require 'supertest'
sundae = require '../src/sundae'

describe 'Sundae', ->

  it 'should use scaffold and run the application', (done) ->
    sundae.scaffold(__dirname).init()
    supertest(sundae.app).get('/users').end (err, res) ->
      res.body.forEach (user) -> user.should.have.properties 'name'
      done err
