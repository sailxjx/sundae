should = require 'should'
express = require 'express'
BaseController = require '../lib/controller'

describe 'Controller', ->

  it 'should mix methods from other instance by mixin function', ->

    class Mixin1

      foo1: ->

      @bar1: 'bar1'

    class Mixin2

      foo2: ->

      @bar2: 'bar2'

    class Custom extends BaseController

      @mixin Mixin1, Mixin2

    custom = new Custom
    Custom.should.have.properties 'bar1', 'bar2'
    custom.should.have.properties 'foo1', 'foo2'
