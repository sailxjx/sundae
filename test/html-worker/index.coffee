sundae = require('../../index')

sundae
  .init()
  .set('root', __dirname)
  .use(sundae.config('default'))
  .use(sundae.error(require('./config/errors')))
  .use(sundae.router(require('./config/routes')))
  .run ->
    process.send('ready') if process.send?