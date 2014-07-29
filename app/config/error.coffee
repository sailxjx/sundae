module.exports = (handler) ->
  handler.locales = ['zh', 'en']
  handler.localeDir = "#{__dirname}/locales"
  handler.map =
    MISSING_PARAMS: 400100
