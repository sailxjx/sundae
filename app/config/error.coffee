module.exports = (handler) ->
  handler.locales = ['zh', 'en']
  handler.localeDir = "#{__dirname}/locales"
  handler.map =
    PARAMS_MISSING: 400100
