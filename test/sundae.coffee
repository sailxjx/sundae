should = require 'should'
supertest = require 'supertest'
express = require 'express'
Sundae = require '../src/sundae'

describe 'Sundae', ->

  app = express()

  it 'should initial the application and load sundae modules', (done) ->
    sundae = Sundae(app)
    sundae.load 'router', require './config/routes'
    sundae.load 'request'
    sundae.load 'response'
    supertest(app).get('/users').end (err, res) ->
      res.body.forEach (user) -> user.should.have.properties 'name'
      done err
