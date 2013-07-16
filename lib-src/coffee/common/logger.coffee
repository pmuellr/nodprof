# Licensed under the Apache License. See footer for details.

_   = require "underscore"

pkg   = require "../../package.json"
utils = require "./utils"

logger = exports

Verbose = false
Debug   = false
Program = pkg.name

#-------------------------------------------------------------------------------
logger.log = (message) ->
    date = utils.formatDate "mh/dd hh:mn:ss"

    console.log "#{Program}: #{date} - #{message}"
    return

#-------------------------------------------------------------------------------
logger.vlog = (message) ->
    return if !Verbose and !Debug

    logger.log message
    return

#-------------------------------------------------------------------------------
logger.dlog = (message) ->
    return if !Debug

    logger.log message
    return

#-------------------------------------------------------------------------------
logger.setVerbose = (verbose) ->
    Verbose = !!verbose
    return 

#-------------------------------------------------------------------------------
logger.setDebug = (debug) ->
    Debug = !!debug
    return 

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
    