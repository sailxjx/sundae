util = require 'util'

appConfigs = require './application'
env = process.env.NODE_ENV
try
  envConfigs = require "./environments/#{env}"
catch e
  envConfigs = require './environments/development'

configs = util._extend(appConfigs, envConfigs)
module.exports = configs
