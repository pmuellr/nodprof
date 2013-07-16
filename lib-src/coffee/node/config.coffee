# Licensed under the Apache License. See footer for details.

fs   = require "fs"
path = require "path"

nopt = require "nopt"
_    = require "underscore"

pkg     = require "../../package.json"
utils   = require "../common/utils"
logger  = require "../common/logger"

#-------------------------------------------------------------------------------
exports.getConfiguration = (argv) ->
    {args, opts} = parseCommandLine argv

    cDef  = getConfigurationDefault()
    cCmd  = getConfigurationCommandLine opts

    cFile = cCmd.config or cDef.config

    cEnv  = getConfigurationEnv()
    cCfg  = getConfigurationConfig cFile

    config = _.defaults {}, cCmd, cEnv, cCfg, cDef

    delete config.config

    data = mkdirp config.data
    if !data?
        logger.log "data directory not found or not writable: #{config.data}"
        process.exit 1

    return {args, config}

#-------------------------------------------------------------------------------
mkdirp = (dir) ->
    exists = fs.existsSync dir

    if exists
        stats = fs.statSync dir
        return null if !stats.isDirectory()
        return dir

    parent = path.dirname dir 
    result = mkdirp parent
    return null if !result?

    try
        fs.mkdirSync dir   
    catch e
        return null
    
    return dir

#-------------------------------------------------------------------------------
getConfigurationDefault = ->
    result = 
        verbose:    false
        debug:      false
        serve:      false
        port:       3000
        heap:       true
        profile:    true
        data:       utils.replaceTilde "~/.#{pkg.name}/data"
        config:     utils.replaceTilde "~/.#{pkg.name}/config.json"

    return result

#-------------------------------------------------------------------------------
getConfigurationConfig = (file) ->
    try 
        contents = fs.readFileSync file, "utf8"
        contents = JSON.parse contents
    catch e 
        contents = {}

    return contents

#-------------------------------------------------------------------------------
getConfigurationEnv = ->

    result = {}

    port = process.env.PORT
    result.port = port if port?

    return result

#-------------------------------------------------------------------------------
getConfigurationCommandLine = (opts) ->
    return opts

#-------------------------------------------------------------------------------
parseCommandLine = (argv) ->

    optionSpecs =
        verbose:    Boolean
        debug:      Boolean
        serve:      Boolean
        heap:       Boolean
        profile:    Boolean
        port:       Number
        data:       path
        config:     path
        help:       Boolean

    shortHands =
        v:   "--verbose"
        d:   "--debug"
        s:   "--serve"
        h:   "--heap"
        r:   "--profile"
        p:   "--port"
        d:   "--data"
        c:   "--config"
        "?": "--help"

    exports.help() if argv[0] == "?"

    parsed = nopt(optionSpecs, shortHands, argv, 0)

    exports.help() if parsed.help

    args = parsed.argv.remain
    opts = parsed

    delete opts.argv
    
    return {args, opts}

#-------------------------------------------------------------------------------
# print some help and then exit
#-------------------------------------------------------------------------------
exports.help = ->
    text =  """
            #{pkg.name} #{pkg.version}

                will run an HTTP server to display profiling results,
                or profile the execution of a node module

            usage:
                #{pkg.name} [options] [arguments]

            options:
                -c --config  path
                -v --verbose 
                -x --debug 
                -p --port    Number
                -d --data    path
                -s --serve 
                -r --profile boolean

            Using the --serve option will run the server, else the remainder
            of the command line will be used as the node module to profile.

            See the `README.md` file for #{pkg.name} for more information.
            """
    console.log text
    process.exit()

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
    