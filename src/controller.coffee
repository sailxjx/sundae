class BaseController

  decorators: [
    require './decorators/ensure'
    require './decorators/filter'
    require './decorators/assembler'
    require './decorators/select'
    require './decorators/post'
  ]

module.exports = BaseController
