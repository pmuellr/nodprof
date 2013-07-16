# Licensed under the Apache License. See footer for details.

http = require "http"
path = require "path"

express  = require "express"

pkg        = require "../../package.json"
utils      = require "../common/utils"
logger     = require "../common/logger"
middleware = require "./middleware"

WWWDIR = path.join __dirname, "../../www"

#-------------------------------------------------------------------------------
exports.run = (config) ->
    favIcon = path.join WWWDIR, "images/icon-032.png"

    app = express()

    app.on "error", (error) -> logger.log error
    app.use express.favicon(favIcon)
    app.use "/", middleware(config)
    app.use express.errorHandler dumpExceptions: true

    logger.log "starting server at http://localhost:#{config.port}"
    logger.dlog "configuration: #{utils.JL config}"

    app.listen config.port

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
    