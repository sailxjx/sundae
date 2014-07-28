all: test

test:
	@NODE_ENV=mocha ./node_modules/.bin/mocha 	\
	    --require should 				\
	    --reporter spec test/index.js

.PHONY: all test
