# Licensed under the Apache License. See footer for details.

SUPERVISOR = node_modules/.bin/supervisor
BROWSERIFY = node_modules/.bin/browserify
COFFEE     = node_modules/.bin/coffee
COFFEEC    = $(COFFEE) --bare --compile

# prefer installed scripts
PATH:=./node_modules/.bin:${PATH}

#-------------------------------------------------------------------------------
help:
	@echo "available targets:"
	@echo ""
	@echo "build:     build the natives"
	@echo "coffee:    build the coffee files"
	@echo "clean:     clean up the binaries and tmp directory"
	@echo "distclean: clean up the lib and node_modules directories"
	@echo "test:      run tests"

#-------------------------------------------------------------------------------
watch:
	@$(SUPERVISOR) \
		--watch      lib-src,test,samples,www-src \
		--extensions coffee,html,css,cpp,h \
		--exec make build-n-serve

#	@wr "make build" lib-src test samples www-src

#-------------------------------------------------------------------------------
build: make-writeable build_ make-read-only

#-------------------------------------------------------------------------------
build-n-serve: build-n-serve-notice build serve

build-n-serve-notice:
	@echo ----------------------------------------------------------------------
	@echo building then serving	

#-------------------------------------------------------------------------------
serve: 
	@node lib/node/cli.js --serve

#-------------------------------------------------------------------------------
make-writeable: 
	@-chmod -R +w www/* lib/*

#-------------------------------------------------------------------------------
make-read-only: 
	@-chmod -R -w www/* lib/*

#-------------------------------------------------------------------------------
build_: natives coffee www

#-------------------------------------------------------------------------------
www:
	@echo building web assets
	@rm -rf www/*
	@cd www; mkdir css images scripts vendor

	@cp -R www-src/*    www
	@cp -R vendor/*     www/vendor

	@$(BROWSERIFY) \
		--debug \
		--outfile www/scripts/all-modules.js \
		lib/www/index.js

	@$(COFFEE) tools/split-sourcemap-data-url.coffee www/scripts/all-modules.js

#-------------------------------------------------------------------------------
natives: build/Release/nodprof_natives.node

#-------------------------------------------------------------------------------
build/Release/nodprof_natives.node: lib-src/cpp/*.cc lib-src/cpp/*.h
	@if [ ! -d ./build ]; then node-gyp configure; fi
	@node-gyp build

#-------------------------------------------------------------------------------
coffee:
	@echo compiling coffee files
	@mkdir -p lib
	@rm -rf   lib/*
	@$(COFFEEC) --output lib lib-src/coffee
	@$(COFFEEC) --output samples samples/*.coffee


#-------------------------------------------------------------------------------
clean:
	@node-gyp clean
	@rm -rf tmp

#-------------------------------------------------------------------------------
distclean: clean
	@rm -rf lib node_modules

#-------------------------------------------------------------------------------
samples: build
	@mkdir -p tmp
	@echo running samples
	node lib/node/cli samples/delta-blue

#-------------------------------------------------------------------------------
test: build
	@rm -rf   tmp
	@mkdir -p tmp
	@echo running tests
	@mocha --compilers coffee:coffee-script --reporter dot test/*-test.coffee

#-------------------------------------------------------------------------------
vendor: 
	@-rm -rf  vendor/*
	@mkdir -p vendor

	@echo ""
	@echo "downloading jQuery"
	@curl --progress-bar --output vendor/jquery.js   $(JQUERY_URL).js

	@echo ""
	@echo "downloading angular"
	@curl --progress-bar --output vendor/angular.js  $(ANGULAR_URL)/angular.js

	@echo ""
	@echo "downloading bootstrap"
	@mkdir -p vendor/bootstrap
	@curl --progress-bar --output vendor/bootstrap/bootstrap.zip $(BOOTSTRAP_URL)

	@unzip -q vendor/bootstrap/bootstrap.zip -d vendor/bootstrap
	@mv       vendor/bootstrap/bootstrap/*      vendor/bootstrap
	@rm -r    vendor/bootstrap/bootstrap
	@rm       vendor/bootstrap/bootstrap.zip
	@rm       vendor/bootstrap/css/*.min.css
	@rm       vendor/bootstrap/js/*.min.js

	@echo ""
	@echo "downloading font-awesome"
	@mkdir -p vendor/font-awesome
	@curl --progress-bar --output vendor/font-awesome/font-awesome.zip $(FONTAWESOME_URL)
	@unzip -q vendor/font-awesome/font-awesome.zip -d vendor/font-awesome
	@mv       vendor/font-awesome/font-awesome/*      vendor/font-awesome
	@rm -rf   vendor/font-awesome/font-awesome
	@rm       vendor/font-awesome/font-awesome.zip
	@rm       vendor/font-awesome/css/*.min.css
	@rm -rf   vendor/font-awesome/less

#-------------------------------------------------------------------------------
JQUERY_URL      = http://code.jquery.com/jquery-2.0.2
ANGULAR_URL     = https://ajax.googleapis.com/ajax/libs/angularjs/1.1.5
BOOTSTRAP_URL   = http://twitter.github.io/bootstrap/assets/bootstrap.zip
FONTAWESOME_URL = http://fortawesome.github.io/Font-Awesome/assets/font-awesome.zip

#-------------------------------------------------------------------------------
icons:
	@echo converting icons with ImageMagick

	@convert -resize 032x032 www-src/images/icon-512.png  www-src/images/icon-032.png
	@convert -resize 057x057 www-src/images/icon-512.png  www-src/images/icon-057.png
	@convert -resize 064x064 www-src/images/icon-512.png  www-src/images/icon-064.png
	@convert -resize 072x072 www-src/images/icon-512.png  www-src/images/icon-072.png
	@convert -resize 096x096 www-src/images/icon-512.png  www-src/images/icon-096.png
	@convert -resize 114x114 www-src/images/icon-512.png  www-src/images/icon-114.png
	@convert -resize 128x128 www-src/images/icon-512.png  www-src/images/icon-128.png
	@convert -resize 128x128 www-src/images/icon-512.png  www-src/images/icon-256.png

#-------------------------------------------------------------------------------
.PHONY: help watch build coffee www clean distclean test vendor

#-------------------------------------------------------------------------------
# Copyright 2013 I.B.M.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#-------------------------------------------------------------------------------
