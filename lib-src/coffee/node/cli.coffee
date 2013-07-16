# Licensed under the Apache License. See footer for details.

fs   = require "fs"
path = require "path"

nopt = require "nopt"
_    = require "underscore"

pkg      = require "../../package.json"
nodprof  = require "../.."
utils    = require "../common/utils"
logger   = require "../common/logger"
config   = require "./config"
profiler = require "./profiler"
server   = require "./server"

cli = exports

#-------------------------------------------------------------------------------
cli.run = ->
    {args, config} = config.getConfiguration process.argv[2..]

    logger.setDebug   config.debug
    logger.setVerbose config.verbose

    if config.serve
        server.run   config
    else
        profiler.run {args, config}

#-------------------------------------------------------------------------------
cli.run() if require.main is module

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
    