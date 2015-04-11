should = require 'should'
supertest = require 'supertest'
express = require 'express'
sundae = require '../src/sundae'

describe 'sundae', ->

  it 'load sundae and register resource function on app', (done) ->

    app = sundae express()

    app.should.have.properties 'resource'

    # The origial app methods should still work
    app.get '/', (req, res) -> res.end 'ok'

    supertest(app).get('/').end (err, res) ->
      res.text.should.eql 'ok'
      done err
