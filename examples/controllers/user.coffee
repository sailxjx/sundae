sundae = require '../..'

module.exports = sundae.controller 'User', ->

  @before ...,
    only:
    except:

  @ensure ...

  @after ...

  @action ...  # Register a single action

  @actions ... # Register actions

  @finish  # Manually finish the define process of action

  @before  # Define other hooks of this controller

