sundae = require 'sundae'
sundae.set('port', 7000).scaffold(__dirname).run ->
  console.log '''
    Server started!
    Now visit http://localhost:7000
    To see the welcome message
  '''
