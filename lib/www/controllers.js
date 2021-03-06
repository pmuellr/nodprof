// Generated by CoffeeScript 1.6.3
var BodyController, addControllers, getSampleDays, partitionFilesByDays, profileView, _,
  __hasProp = {}.hasOwnProperty;

_ = require("underscore");

profileView = require("./profileView");

module.exports = function(mod) {
  addControllers(mod, {
    BodyController: BodyController
  });
};

BodyController = function($scope, $http) {
  $scope.refreshFiles = function() {
    var httpResponse;
    httpResponse = $http.get("api/files.json");
    httpResponse.success(function(data, status, headers, config) {
      return $scope.days = partitionFilesByDays(data);
    });
    return httpResponse.error(function(data, status, headers, config) {
      return $scope.error = "error getting files: " + status;
    });
  };
  $scope.showProfile = function(file) {
    return profileView.show(file, $scope, $http);
  };
  $scope.showHeap = function(file) {
    return $scope.error = "woulda showed heap for " + file;
  };
  $scope.profileStart = function(event) {
    var httpResponse;
    event.preventDefault();
    httpResponse = $http.post("api/profileStart");
    httpResponse.success(function(data, status, headers, config) {});
    return httpResponse.error(function(data, status, headers, config) {
      return $scope.error = "error starting profile: " + status;
    });
  };
  $scope.profileStop = function(event) {
    var httpResponse;
    event.preventDefault();
    httpResponse = $http.post("api/profileStop");
    httpResponse.success(function(data, status, headers, config) {
      return setTimeout((function() {
        return $scope.refreshFiles();
      }), 2000);
    });
    return httpResponse.error(function(data, status, headers, config) {
      return $scope.error = "error starting profile: " + status;
    });
  };
  $scope.resizeChart = function(chart$) {
    var chartWidth, height, svg$, width;
    svg$ = $("svg", chart$);
    width = svg$.attr("width");
    height = svg$.attr("height");
    chartWidth = chart$.width();
    height = height * chartWidth / width;
    width = chartWidth;
    svg$.attr({
      width: width,
      height: height
    });
  };
  $scope.resizeCharts = function() {
    var chart, charts$, _i, _len, _results;
    charts$ = $("#content .chart");
    _results = [];
    for (_i = 0, _len = charts$.length; _i < _len; _i++) {
      chart = charts$[_i];
      _results.push($scope.resizeChart($(chart)));
    }
    return _results;
  };
  $scope.appName = "nodprof";
  $scope.error = null;
  $scope.days = [];
  $scope.refreshFiles();
  $(window).resize(function(event) {
    return $scope.resizeCharts();
  });
};

partitionFilesByDays = function(files) {
  var date, dateEntry, dates, days, entries, file, match, pattern, result, time, timeEntry, times, type, _i, _j, _k, _len, _len1, _len2;
  pattern = /.*?(\d{4}-\d{2}-\d{2})-(\d{2}-\d{2}-\d{2})-(\w{4}).*/;
  days = {};
  for (_i = 0, _len = files.length; _i < _len; _i++) {
    file = files[_i];
    match = file.match(pattern);
    if (!match) {
      continue;
    }
    date = match[1];
    time = match[2].replace(/-/g, ":");
    type = match[3];
    dateEntry = days[date];
    if (dateEntry == null) {
      dateEntry = days[date] = {};
    }
    timeEntry = dateEntry[time];
    if (!timeEntry) {
      timeEntry = dateEntry[time] = {
        time: time
      };
    }
    if (type === "prof") {
      timeEntry.prof = file;
    }
  }
  dates = _.keys(days);
  dates.sort();
  dates.reverse();
  result = [];
  for (_j = 0, _len1 = dates.length; _j < _len1; _j++) {
    date = dates[_j];
    dateEntry = days[date];
    times = _.keys(dateEntry);
    times.sort();
    times.reverse();
    entries = [];
    for (_k = 0, _len2 = times.length; _k < _len2; _k++) {
      time = times[_k];
      entries.push(dateEntry[time]);
    }
    result.push({
      date: date,
      entries: entries
    });
  }
  return result;
};

addControllers = function(mod, controllers) {
  var fn, name;
  for (name in controllers) {
    if (!__hasProp.call(controllers, name)) continue;
    fn = controllers[name];
    mod.controller(name, fn);
  }
};

getSampleDays = function() {
  return [
    {
      date: "2013-07-04",
      entries: [
        {
          time: "12:00:00",
          prof: "2013-07-04-12-00-00-prof.json",
          heap: "2013-07-04-12-00-00-heap.json"
        }, {
          time: "12:01:00",
          heap: "2013-07-04-12-01-00-heap.json"
        }
      ]
    }, {
      date: "2013-07-03",
      entries: [
        {
          time: "13:00:00",
          prof: "2013-07-03-13-00-00-prof.json",
          heap: "2013-07-03-13-00-00-heap.json"
        }, {
          time: "13:01:00",
          prof: "2013-07-03-13-01-00-prof.json"
        }
      ]
    }
  ];
};
