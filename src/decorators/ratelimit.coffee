# Set rate limit of this action
# Pattern: ''
#
# Key: controller.action.ip
crypto = require 'crypto'

rateMap = {}
cleanupTimer = null

module.exports = ratelimit = (limitStr, options = {}) ->

  limitation = ratelimit.parseLimit limitStr

  unless cleanupTimer
    cleanupTimer = setInterval ->
      now = Date.now()
      for timeKey, val of rateMap
        [rate, startTime] = timeKey.split '_'
        if ((now / rate) - Number(startTime)) > 1
          delete rateMap[timeKey]
    , 60000

  options.hookFunc = (req, res, callback) ->
    rateKey = crypto.createHash('md5').update("#{req.ctrl}.#{req.action}.#{req.ip}.#{req.headers?['user-agent']}").digest('base64')
    for rate, limit of limitation
      timeKey = "#{rate}_" + Math.floor(Date.now() / 1000 / rate)
      rateMap[timeKey] or= {}
      rateMap[timeKey][rateKey] or= 0
      rateMap[timeKey][rateKey] += 1
      if rateMap[timeKey][rateKey] > limit
        err = new Error('Rate limit exceeded')
        err.phrase = 'RATE_LIMIT_EXCEEDED'
        return callback err
    callback()

  @preHook options

###*
 * Parse format of limit string
 * `10` 10 requests per minute
 * `10 30 150` 10 requests per minute, 30 requests per ten minute, 150 requests per hour
 * `10,20 30,300` 10 requests per 20 seconds, 30 requests per 300 seconds
 * @param  {String|Number} limit
###
ratelimit.parseLimit = (limit) ->
  levels = [60, 600, 3600, 86400]
  if toString.call(limit) is '[object Number]'
    return 60: limit
  else if toString.call(limit) is '[object String]'
    limitation = {}
    parts = limit.split new RegExp(' +')
    parts.forEach (part, i) ->
      [limit, rate] = part.split ','
      if rate and limit
        limitation[rate] = Number(limit)
      else if limit and levels[i]
        limitation[levels[i]] = Number(limit)
      else
        throw new Error("Out of limit's range #{limit}")
    return limitation
  else throw new Error("Invalid limit format #{limit}")
