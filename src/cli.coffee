# Cli commands for sundae
commander = require 'commander'
shelljs = require 'shelljs'

program = commander.command('init')

commander.parse(process.argv)
