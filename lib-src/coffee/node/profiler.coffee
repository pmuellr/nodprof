# Licensed under the Apache License. See footer for details.

fs   = require "fs"
path = require "path"

_    = require "underscore"

nodprof  = require "../.."
utils    = require "../common/utils"
logger   = require "../common/logger"
Services = require("./services").Services

#-------------------------------------------------------------------------------
exports.run = ({args, config}) ->
    require("./config").help() if args.length == 0

    services = new Services config

    mod = args.shift()
    # process.argv.splice(1,1)
    process.argv = [process.argv[0]]
    process.argv.push mod
    for arg in args
        process.argv.push arg

    mod = path.resolve mod

    logger.dlog "profiling module: #{mod}"
    logger.dlog "whacked argv:     #{utils.JS process.argv}"

    profFileName = utils.formatDate "yy-mh-dd-hh-mn-ss-prof.json"
    heapFileName = utils.formatDate "yy-mh-dd-hh-mn-ss-heap.json"

    profFileName = path.join config.data, profFileName
    heapFileName = path.join config.data, heapFileName

    services.profileStart() if config.profile

    global.nodprofProfiling = true
    
    require mod

    process.on "exit", ->
        # services.heapSnapshot() if config.heap
        services.profileStop()  if config.profile

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
    