# Licensed under the Apache License. See footer for details.

_ = require "underscore"

profileView = require "./profileView"

#-------------------------------------------------------------------------------
module.exports = (mod) ->

    addControllers  mod, {
        BodyController
    }

    return

#-------------------------------------------------------------------------------
BodyController = ($scope, $http) ->

    #---------------------------------------------------------------------------
    $scope.refreshFiles = ->
        httpResponse = $http.get "api/files"

        httpResponse.success (data, status, headers, config) ->
            $scope.days = partitionFilesByDays data

        httpResponse.error (data, status, headers, config) ->
            $scope.error "error getting files: #{status}"

    #---------------------------------------------------------------------------
    $scope.showProfile = (file) ->
        profileView.show file, $scope, $http

    #---------------------------------------------------------------------------
    $scope.showHeap = (file) ->
        $scope.error = "woulda showed heap for #{file}"

    #---------------------------------------------------------------------------
    $scope.profileStart = (event) ->
        event.preventDefault()

        httpResponse = $http.post "api/profileStart"

        httpResponse.success (data, status, headers, config) ->

        httpResponse.error (data, status, headers, config) ->
            $scope.error "error starting profile: #{status}"

    #---------------------------------------------------------------------------
    $scope.profileStop = (event) ->
        event.preventDefault()

        httpResponse = $http.post "api/profileStop"

        httpResponse.success (data, status, headers, config) ->
            setTimeout (-> $scope.refreshFiles()), 2000

        httpResponse.error (data, status, headers, config) ->
            $scope.error "error starting profile: #{status}"

    #---------------------------------------------------------------------------
    $scope.appName = "nodprof"
    $scope.error   = null
    $scope.days    = getSampleDays()

    $scope.refreshFiles()

    return

#-------------------------------------------------------------------------------
# "2013-07-12-12-18-54-heap.json"
#  "2013-07-12-12-18-54-prof.json"
partitionFilesByDays = (files) ->

    pattern = /.*?(\d{4}-\d{2}-\d{2})-(\d{2}-\d{2}-\d{2})-(\w{4}).*/
    days = {}
    for file in files
        match = file.match pattern
        continue if !match

        date = match[1]
        time = match[2].replace /-/g, ":"
        type = match[3]

        dateEntry = days[date]
        if !dateEntry?
            dateEntry = days[date] = {}

        timeEntry = dateEntry[time]
        if !timeEntry
            timeEntry = dateEntry[time] = {time}
        
        timeEntry.prof = file if type is "prof"
        # timeEntry.heap = file if type is "heap"

    dates = _.keys days
    dates.sort()
    dates.reverse()

    result = []
    for date in dates
        dateEntry = days[date]

        times = _.keys dateEntry
        times.sort()
        times.reverse()

        entries = []
        for time in times
            entries.push dateEntry[time]

        result.push
            date:    date
            entries: entries

    return result

#-------------------------------------------------------------------------------
addControllers = (mod, controllers) ->
    for own name, fn of controllers
        mod.controller name, fn

    return

#-------------------------------------------------------------------------------
getSampleDays = ->
    return [
        {
            date: "2013-07-04"
            entries: [
                {
                    time: "12:00:00"
                    prof: "2013-07-04-12-00-00-prof.json"
                    heap: "2013-07-04-12-00-00-heap.json"
                }

                {
                    time: "12:01:00"
                    heap: "2013-07-04-12-01-00-heap.json"
                }
            ]
        }

        {
            date: "2013-07-03"
            entries: [
                {
                    time: "13:00:00"
                    prof: "2013-07-03-13-00-00-prof.json"
                    heap: "2013-07-03-13-00-00-heap.json"
                }

                {
                    time: "13:01:00"
                    prof: "2013-07-03-13-01-00-prof.json"
                }
            ]
        }
    ]

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
