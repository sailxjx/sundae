http = require('http')
sundae = require('../../index')

sundae
  .init()
  .set('root', __dirname)
  .use(sundae.config('default'))
  .use(sundae.router(require('./config/routes')))
  .use(sundae.error(require('./config/errors')))
  .run ->
    process.send('ready') if process.send?