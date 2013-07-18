# Licensed under the Apache License. See footer for details.

path = require "path"

express  = require "express"

Services = require("./services").Services
logger   = require "../common/logger"
utils    = require "../common/utils"
config   = require "./config"

WWWDIR   = path.join __dirname, "../../www"
VENDOR   = path.join __dirname, "../../vendor"

defaultConfig = config.getConfiguration([]).config

#-------------------------------------------------------------------------------
module.exports = (config = defaultConfig) ->
    app = express()
    app.on "error", (error) -> logger.log error
    app.set "services", new Services config

    app.use CORSify
    # app.use log

    app.get  "/api/files.json",       getFiles
    app.get  "/api/files/:file.json", getFile
    app.post "/api/profileStart",     profileStart
    app.post "/api/profileStop",      profileStop
    app.post "/api/heapSnapshot",     heapSnapshot

    app.use            express.static(WWWDIR)
    app.use "/vendor", express.static(VENDOR)

    return app

#-------------------------------------------------------------------------------
getFiles = (request, response) ->
    services = request.app.get "services"

    services.getFiles (err, data) ->
        if err? 
            message = "error processing getFiles(): #{err}"
            logger.log message
            response.send 500, message
            return

        response.send data

    return

#-------------------------------------------------------------------------------
getFile = (request, response) ->
    services = request.app.get "services"
    fileName = "#{request.params.file}.json"

    services.getFile fileName, (err, data) ->
        if err? 
            message = "error processing getFile(#{fileName}): #{err}"
            logger.log message
            response.send 500, message
            return

        response.send data

#-------------------------------------------------------------------------------
profileStart = (request, response) ->
    services = request.app.get "services"

    services.profileStart()
    response.send "profile started"
    return

#-------------------------------------------------------------------------------
profileStop = (request, response) ->
    services = request.app.get "services"

    services.profileStop()
    response.send "profile stopped"
    return

#-------------------------------------------------------------------------------
heapSnapshot = (request, response) ->
    services = request.app.get "services"

    services.heapSnapshot()
    response.send "heap snapshot generated"
    return

#-------------------------------------------------------------------------------
CORSify = (request, response, next) ->
    response.header "Access-Control-Allow-Origin:", "*"
    response.header "Access-Control-Allow-Methods", "OPTIONS, GET, POST"

    next()

    return

#-------------------------------------------------------------------------------
log = (request, response, next) ->
    logger.log utils.JL request.url
    # console.log request
    next()

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
    