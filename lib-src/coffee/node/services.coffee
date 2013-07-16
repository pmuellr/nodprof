# Licensed under the Apache License. See footer for details.

fs   = require "fs"
path = require "path"

express  = require "express"

nodprof  = require "../.."
utils    = require "../common/utils"
logger   = require "../common/logger"

services = exports

#-------------------------------------------------------------------------------
services.Services = class Services

    #---------------------------------------------------------------------------
    constructor: (@config) ->

    #---------------------------------------------------------------------------
    getFiles: (callback) ->

        fs.readdir @config.data, (err, files) ->
            callback err, files

    #---------------------------------------------------------------------------
    getFile: (fileName, callback) ->
        
        fileName = path.basename fileName
        unless fileName.match(/.\.json$/)
            err = new Error "not a JSON file"
            callback err, null
            return

        fileName = path.join @config.data, fileName
        fs.exists fileName, (exists) ->
            unless exists
                err = new Error "file not found"
                callback err, null
                return

            fs.readFile fileName, (err, data) ->
                callback err, data

    #---------------------------------------------------------------------------
    profileStart: -> 
        nodprof.profileStart()
        logger.log "profiling started"

    #---------------------------------------------------------------------------
    profileStop: -> 
        prof = nodprof.profileStop()
        return if !prof?

        profFileName = utils.formatDate "yy-mh-dd-hh-mn-ss-prof.json"
        profFileName = path.join @config.data, profFileName

        fs.writeFileSync profFileName, utils.JS prof, "utf8"

        logger.log "profiling stopped; results written to #{profFileName}"

    #---------------------------------------------------------------------------
    heapSnapshot: ->
        heap = nodprof.heapSnapshot()

        heapFileName = utils.formatDate "yy-mh-dd-hh-mn-ss-heap.json"
        heapFileName = path.join @config.data, heapFileName

        fs.writeFileSync heapFileName, utils.JS heap, "utf8"

        logger.log "heap snapshot taken; results written to #{heapFileName}"

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
    