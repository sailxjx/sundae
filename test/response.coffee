should = require 'should'
async = require 'async'
express = require 'express'
supertest = require 'supertest'

response = require '../lib/response'

describe 'Response', ->

  app = express()

  before -> response.config app, (res) -> res.parse = ->

  it 'should patch the origin response object and add parse function', (done) ->

    app.use (req, res) ->
      res.should.have.properties('parse')
      res.json('ok')

    supertest(app).get('/').end(done)

  after -> response.config app, (res) ->
