# Licensed under the Apache License. See footer for details.

fs = require "fs"

utils = exports

#-------------------------------------------------------------------------------
utils.trim = (string) ->
    string.replace(/(^\s+)|(\s+$)/g,'')

#-------------------------------------------------------------------------------
utils.datedFileName = (date = new Date) ->
    return utils.formatDate "yy-mh-dd-hh-mn-ss"

#-------------------------------------------------------------------------------
utils.loggedDate = (date = new Date) ->
    return utils.formatDate "mh/dd hh:mn:ss", date

#-------------------------------------------------------------------------------
utils.formatDate = (format, date = new Date) ->
    yy = date.getFullYear()
    mh = date.getMonth() + 1
    dd = date.getDate()
    hh = date.getHours()
    mn = date.getMinutes()
    ss = date.getSeconds()

    mh = utils.alignRight mh, 2, "0"
    dd = utils.alignRight dd, 2, "0"
    hh = utils.alignRight hh, 2, "0"
    mn = utils.alignRight mn, 2, "0"
    ss = utils.alignRight ss, 2, "0"

    return format
        .replace("yy", yy)
        .replace("mh", mh)
        .replace("dd", dd)
        .replace("hh", hh)
        .replace("mn", mn)
        .replace("ss", ss)

#-------------------------------------------------------------------------------
utils.alignLeft = (string, length, pad=" ") ->
    while string.length < length
        string = "#{string}#{pad}"

    return string

#-------------------------------------------------------------------------------
utils.alignRight = (string, length, pad=" ") ->
    string = "#{string}"
    pad    = "#{pad}"

    while string.length < length
        string = "#{pad}#{string}"

    return string

#-------------------------------------------------------------------------------
utils.replaceTilde = (fileName) ->
    tilde = process.env["HOME"] || process.env["USERPROFILE"] || '.'
    return fileName.replace('~', tilde)

#-------------------------------------------------------------------------------
utils.JL = (object) -> return JSON.stringify object, null, 4

#-------------------------------------------------------------------------------
utils.JS = (object) -> return JSON.stringify object

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
