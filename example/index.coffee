sundae = require('../index')
logger = require('graceful-logger')

port = 3010
sundae.init({
    port: port
  })
  .set('root', __dirname)
  .use(sundae.config('default'))
  .use(sundae.error(require('./config/errors')))
  .use(sundae.router(require('./config/routes')))
  .run ->
    logger.info("Server running on #{port}")