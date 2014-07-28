should = require 'should'
fs = require 'fs'
path = require 'path'
sh = require 'shelljs'
cli = require '../lib/cli'

clean = ->
  sh.rm '-rf', path.join(__dirname, 'app')

cli.fail = (msg) ->
  console.error "  \u001b[32mFAIL:\u001b[39m #{msg}"
  return new Error(msg)

cli.succ = (msg) ->
  console.log "  \u001b[31mSUCC:\u001b[39m finish"
  return true

describe 'Cli#Init', ->

  before clean

  it 'should check the target directory and throw error when target is not empty', (done) ->

    cli.init(__dirname).message.should.containEql 'exist'


  it 'should init the application in app directory', (done) ->

    cli.init(path.join(__dirname, 'app')).should.eql true

  # after clean
