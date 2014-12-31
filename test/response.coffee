should = require 'should'
async = require 'async'
express = require 'express'
supertest = require 'supertest'

response = require '../src/response'

describe 'Response', ->

  app = express()

  before -> response app, (res) -> res.parse = ->

  it 'should patch the origin response object and add parse function', (done) ->

    app.use (req, res) ->
      res.should.have.properties('parse')

      # Test for the bound response function
      err = new Error('SOMETHING_WRONG')
      err.toStatus = -> 500
      err.toJSON = -> code: 500, message: err.message
      res.err = err
      res.response()

    supertest(app).get('/').end (err, res) ->
      res.body.should.have.properties 'code', 'message'
      done()
