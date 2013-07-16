# Licensed under the Apache License. See footer for details.

fs   = require "fs"
path = require "path"

exports.run = (times) ->
    console.log "running #{__filename}"
    for i in [0..times]
        setTimeout (-> runOuter times), 100 * i

runOuter = (times) ->
    runInner (times)

runInner = (times) ->
    for i in [0..times]
        entries = fs.readdirSync "."

if require.main is module or global.nodprofProfiling
    exports.run 50

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
    