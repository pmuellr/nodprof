# Licensed under the Apache License. See footer for details.

assert  = require "assert"
fs      = require "fs"
nodprof = require "../lib"

describe "profile", ->

    it "should generate some profiling data", ->

        for i in [0...1000]
            fs.readFileSync __dirname + "/../package.json", "utf8"

        snapshot = nodprof.heapSnapshot()
        
        snapshot = JSON.stringify snapshot, null, 4
        fs.writeFileSync "#{__dirname}/../tmp/snapshot.json", snapshot


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
