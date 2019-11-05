export PATH := $(PATH):./node_modules/.bin

.PHONY: test docs

test-dev:
	karma start --browsers=Chrome

test-chrome:
	karma start --single-run --browsers=Chrome

test-firefox:
	karma start --single-run --browsers=Firefox

test-unit:
	mocha test/server.js

test-esm:
	node --experimental-modules -r esm node_modules/mocha/bin/_mocha test/server.js

test-node6: transpile
	node test/node6.js

lint-ci:
	eslint --ignore-pattern test/fixtures/* src test
	prettier *.md
	dtslint --expectOnly types

lint:
	eslint --cache --fix .
	prettier --write *.md
	dtslint --expectOnly types

coverage-report:
	nyc --reporter=lcovonly --reporter=text mocha test/server.js
	cat ./coverage/lcov.info | coveralls

local-coverage:
	nyc --reporter=html --reporter=text mocha test/server.js

transpile:
	babel src --out-dir es5

build: transpile
	if [ ! -d "esm" ]; then mkdir esm; fi
	cp -r src/* esm
	rollup -c rollup.config.js
	touch cjs/package.json
	echo '{"type": "commonjs"}' > cjs/package.json

docs:
	cd docs; jekyll serve build --watch
