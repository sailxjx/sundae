should = require 'should'
express = require 'express'
async = require 'async'
supertest = require 'supertest'
sundae = require '../src/sundae'

describe 'Sundae#Request', ->

  app = sundae express()

  req = app.request
  req.importKeys = ['_id']
  req.allowedKeys = ['_id', 'name', 'email', 'location', 'fullname']
  req.alias = address: 'location'
  req.validators = fullname: (fullname) -> fullname.length < 10
  req.setters = email: (email) -> @email = email

  it 'should apply the alias/validators/setters when call set method', (done) ->
    # Test setters
    app.use (req, res) ->
      # Test importKeys
      req.set '_id', 1
      req._id.should.eql 1

      # Test allowdKeys
      req.set 'name', 'Grace'
      req.set 'nickname', 'GG', true
      req.get().should.have.properties 'name'
      req.get().should.not.have.properties 'nickname'

      # Test alias
      req.set 'address', 'Shanghai'
      req.get('location').should.eql 'Shanghai'

      # Test validators
      err = req.set 'fullname', 'Brfxxccxxmnpcccclllmmnprxvclmnckssqlbb1111b'
      err.message.should.eql 'Param fullname is invalid'
      req.get().should.not.have.properties 'fullname'

      # Test setters
      req.set 'email', 'grace@gmail.com'
      req.email.should.eql 'grace@gmail.com'

      # Test remove
      req.remove '_id'
      should(req._id).eql undefined
      should(req.get('_id')).eql undefined

      res.end 'ok'

    supertest(app).get('/').end (err, res) ->
      res.text.should.eql 'ok'
      done err
