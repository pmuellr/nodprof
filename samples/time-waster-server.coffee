# Licensed under the Apache License. See footer for details.

fs   = require "fs"
path = require "path"

express = require "express"

nodprof    = require ".."
timeWaster = require "./time-waster"

port = process.env.PORT || 3001

#-------------------------------------------------------------------------------
exports.runServer = ->
    app = express()

    app.use "/nodprof/", nodprof.middleware()
    app.use (request, response, next) ->
        response.send """
            <p>This page runs a benchmark, try profiling it.
            <ul>
            <li>Click on this link to the profile to open it in a new tab:
            [<a target="blank"href='nodprof/'>open profiler</a>]
            <li>In the profiling tab, click "Start Profiling"
            <li>In this tab, reload the page, which will run an expensive task
            <li>In the profiling tab, click "Stop Profiling"
            <li>In the profiling tab, reload the page, and the result
            should be added in the left-hand navigator.  The expensive functions
            <tt>runInner()</tt> and <tt>runOuter()</tt> should show up here.
            </ul>
            """
        timeWaster.run 50

    console.log "starting server at http://localhost:#{port}"

    app.listen port

#-------------------------------------------------------------------------------
if require.main is module
    exports.runServer()

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
    