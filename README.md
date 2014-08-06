sundae
======

Rtf restful framework for node

[![NPM version][npm-image]][npm-url] [![Build Status][travis-image]][travis-url]

# Intro

Sundae is a light weight api framework based on express, but more intesting than express.

# Application Structure
```
- app
  - config          Application configs.
                    Include 'request', 'response', 'express', 'routes', etc.
  - controllers     Application controllers
  - mailers         Codes deal with mails
  - util            Utility static methods
  - mixers          Codes you want to share between controllers.
                    it's something like 'lib' directory,
                    but the purpose is more clear than 'libraries'.
                    Someone (like me) may confused with how to share codes between controllers,
                    usually you can put these codes in `ApplicationController` or other base controllers.
                    But for most of time, `include` is better than `extend`,
                    so I'd like to put these codes in a different path, and `mix` them in.
                    sundae will auto mix these modules to the controllers with same name
                    you can define the `mixers` property in controller
                    to mixin the modules with different name.
```

# TODO

# Changelog
## v0.1.5
* change router to singleton, add router _stack

## v0.1.4
* fix post decorator bug

## v0.1.3
* add assembler, post decorators
* fix mixer loader

## v0.1.2
* auto load mixers

## v0.1.1
* add more comments in demo controllers
* fix request reset params bug
* fix cli init crash

## v0.1.0
* new beginning of sundae framework

[npm-url]: https://npmjs.org/package/sundae
[npm-image]: http://img.shields.io/npm/v/sundae.svg

[travis-url]: https://travis-ci.org/sailxjx/sundae
[travis-image]: http://img.shields.io/travis/sailxjx/sundae.svg
