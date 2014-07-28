# Cli commands for sundae
commander = require 'commander'
sh = require 'shelljs'
fs = require 'fs'
async = require 'async'
path = require 'path'

cli =
  init: (mainPath) ->
    try
      files = fs.readdirSync mainPath
    catch e
    return cli.fail "Path [#{mainPath}] is exist and not empty!" if files?.length

    # Copy app files
    msg = "copy files to #{mainPath} ..."
    cli.exec msg
    sh.cp '-rf', path.join(__dirname, '../app/'), mainPath
    cli.pass msg

    # Install dependencies
    msg = "install dependencies"
    cli.exec msg
    sh.cd mainPath
    return cli.fail msg unless sh.exec('npm install').code is 0
    cli.pass msg

  exec: (msg) -> console.log "  \u001b[36mEXEC:\u001b[39m #{msg}"

  pass: (msg) -> console.log "  \u001b[32mPASS:\u001b[39m #{msg}"

  fail: (msg) ->
    console.error "  \u001b[32mFAIL:\u001b[39m #{msg}"
    process.exit(0)

  succ: (msg) ->
    console.log "  \u001b[31mSUCC:\u001b[39m #{msg}"
    process.exit(1)

commander
  .command 'init'
  .description 'prepare for the application folder'
  .usage '[app]'
  .action (app) ->
    app = '' unless toString.call(app) is '[object String]'
    _init path.resolve(app)

commander.parse(process.argv)

commander.help() if process.argv.length < 3

module.exports = cli
