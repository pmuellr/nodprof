# Licensed under the Apache License. See footer for details.

fs   = require "fs"
path = require "path"

PROGRAM = path.basename(__filename)

iFileName = process.argv[2]
oFileName = "#{iFileName}.map"

# console.log "#{PROGRAM} #{iFileName} -> #{oFileName}"

iFile     = fs.readFileSync iFileName, "utf8"

match = iFile.match /\/\/@ sourceMappingURL=data:application\/json;base64,(.*)\n/
if !match? 
    console.log "no sourcemap in file"
    process.exit()
    
data64 = match[1]
data   = new Buffer(data64, "base64").toString("ascii")

data = JSON.parse(data)

cwd        = process.cwd()
sources    = data.sources
newSources = []

for source in sources
    source = path.relative(cwd, source)

    match = source.match /node_modules\/browserify\/node_modules(.*)/
    if match
        source = match[1]
        
    match = source.match /www\/scripts\/(.*)/
    if match
        source = match[1]
        
    newSources.push source

data.sources = newSources
data = JSON.stringify data, null, 4

oFileBaseName = path.basename oFileName

regex = /\/\/@ sourceMappingURL=data:application\/json;base64,(.*)\n/
repl  = "//@ sourceMappingURL=#{oFileBaseName}\n"
iFile = iFile.replace regex, repl

fs.writeFileSync iFileName, iFile
fs.writeFileSync oFileName, data

# console.log "#{PROGRAM} rewrote, removing data url: #{iFileName}"
# console.log "#{PROGRAM} generated new source map:   #{oFileName}"

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
