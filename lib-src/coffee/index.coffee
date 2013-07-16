# Licensed under the Apache License. See footer for details.

nodprof_natives = require("bindings")("nodprof_natives.node")

nodprof = exports

#-------------------------------------------------------------------------------
pkg             = require "../package.json"
nodprof.version = pkg.version

Profiling   = false
DateStarted = null

#-------------------------------------------------------------------------------
nodprof.middleware = require "./node/middleware"

#-------------------------------------------------------------------------------
nodprof.profileStart = ->
    return if Profiling

    Profiling   = true
    DateStarted = new Date

    nodprof_natives.profilerStart()

    return

#-------------------------------------------------------------------------------
nodprof.profileStop = ->
    return null if !Profiling

    Profiling = false

    result = nodprof_natives.profilerStop()
    result.dateStarted = DateStarted
    result.dateStopped = new Date

    return result

#-------------------------------------------------------------------------------
nodprof.isProfiling = ->
    return Profiling

#-------------------------------------------------------------------------------
nodprof.heapSnapshot = ->
    date = new Date

    result = nodprof_natives.heapSnapShotTake()
    result.date = date

    return result

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
