http = require('http')
sundae = require('../../index')

sundae
  .init()
  .set('root', __dirname)
  .use(sundae.config('default'))
  .use(sundae.error(require('./config/errors')))
  .use(sundae.router(require('./config/routes')))

# sundae.app.use (req, res, next) ->
  # res.send('404')

sundae.run ->
  process.send('ready') if process.send?