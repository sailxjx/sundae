# Set rate limit of this action
# Pattern: ''
#
# Key: controller.action.ip
crypto = require 'crypto'

rateMap = {}
cleanupTimer = null

module.exports = ratelimit = (limit, options = {}) ->

  unless cleanupTimer
    cleanupTimer = setInterval ->
      now = Date.now() / 60000
      for timeKey, val of rateMap
        if (now - timeKey) > 1
          delete rateMap[timeKey]
        else break
    , 60000

  options.hookFunc = (req, res, callback) ->
    rateKey = crypto.createHash('md5').update("#{req.ctrl}.#{req.action}.#{req.ip}").digest('base64')
    timeKey = Math.floor(Date.now() / 60000)
    rateMap[timeKey] or= {}
    rateMap[timeKey][rateKey] or= 0
    rateMap[timeKey][rateKey] += 1
    if rateMap[timeKey][rateKey] > limit
      err = new Error('Rate limit exceeded')
      err.phrase = 'RATE_LIMIT_EXCEEDED'
      return callback err
    callback()

  @preHook options



