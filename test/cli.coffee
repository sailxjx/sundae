should = require 'should'
fs = require 'fs'
path = require 'path'
sh = require 'shelljs'
cli = require '../src/cli'

clean = ->
  sh.rm '-rf', path.join(__dirname, 'app')

cli.fail = (msg) ->
  console.error "  \u001b[31mFAIL:\u001b[39m #{msg}"
  return new Error(msg)

cli.succ = (msg) ->
  console.log "  \u001b[32mSUCC:\u001b[39m #{msg}"
  return true

describe 'Cli#Init', ->

  @timeout 30000

  before clean

  it 'should check the target directory and throw error when target is not empty', ->

    cli.init(__dirname).message.should.containEql 'exist'


  it 'should init the application in app directory', ->

    cli.init(path.join(__dirname, 'app')).should.eql true

  after clean
