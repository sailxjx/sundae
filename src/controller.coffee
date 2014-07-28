class BaseController

  decorators: [
    require './decorators/ensure'
    require './decorators/filter'
    require './decorators/select'
  ]

module.exports = BaseController
