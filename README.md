<!-- Licensed under the Apache License. See footer for details. -->

<style>
.object-def {
    width:          100%;
    margin-left:    3em;
}
.object-def .name, .object-def .type {
    font-family:    monospace;
    font-weight:    bold;
    white-space:    nowrap;
    width:          25%;
}
.object-def .type {
    font-style:     italic;
}
.object-def td {
    vertical-align: top;
    padding-right:  2em;
}
</style>

`nodprof` - profiling for node.js
================================================================================

<!-- ======================================================================= -->

`nodprof` command line
--------------------------------------------------------------------------------

The `nodprof` command can be used to:

* run a node.js module and profile the execution
* start an HTTP server used to display profiling results

When profiling a node.js module, the profiling results will be stored in a 
JSON file in a directory indicated by the `nodprof` configuration.  

The `nodprof` HTTP server provides a viewer for these profiling results.  You
can also use the `nodprof` module API to add the `nodprof` viewer to your own
application via middleware.

To run the server, use the `--serve` option.  If the `--serve` option isn't
used then `nodprof` will run the remainder of the command-line as a module
invocation and profile the execution.

When profiling a module, profiling will be started, 
the module will be `require()`d, and when `process` emits the `exit` event,
profiling will be stopped and the data written out.

<!-- ======================================================================= -->

example command line invocation
--------------------------------------------------------------------------------

    sudo npm -g install nodprof
    nodprof --serve --port 8081&
    nodprof `which npm` info grunt
    open http://localhost:8081

This will:

* install `nodprof` globally
* start the `nodprof` server on port 8081
* profile `npm info grunt`
* open a browser to view the results

<!-- ======================================================================= -->

`nodprof` configuration
--------------------------------------------------------------------------------

`nodprof` uses a configuration to determine the values of various twiddleable
values it uses.  These values can be set in the following places, listed in
precedence order:

* command line options
* environment variables
* configuration file values
* default values

<!-- ======================================================================= -->

### command line options ###

options specified as <tt><i>Boolean</i></tt> can be specified without a 
Boolean value, in which case the value is assumed to be true.

<table class='object-def'>
<tr><td class=name>-c --config <td class=type> path <td>
    the location of the configuration file
<tr><td class=name>-v --verbose <td class=type> Boolean <td>
    be noisy
<tr><td class=name>-x --debug <td class=type> Boolean <td>
    be very noisy
<tr><td class=name>-p --port <td class=type> Number <td>
    the HTTP port when running the server
<tr><td class=name>-d --data <td class=type> path <td>
    the directory to use to read and write profiling data
<tr><td class=name>-s --serve <td class=type> Boolean <td>
    run the HTTP server
<tr><td class=name>-h --heap <td class=type> Boolean <td>
    generate a heap snapshot
<tr><td class=name>-r --profile <td class=type> Boolean <td>
    generate a profile
</table>

<!-- ======================================================================= -->

### environment variables ###

<table class='object-def'>
<tr><td class=name>PORT <td class=type> Number <td>
    the HTTP port when running the server
</table>

<!-- ======================================================================= -->

### configuration file values ###

The configuration file is a JSON file whose content is an object
with the following properties:

<table class='object-def'>
<tr><td class=name>verbose <td class=type> Boolean <td>
    same as <tt>--verbose</tt>
<tr><td class=name>debug <td class=type> Boolean <td>
    same as <tt>--debug</tt>
<tr><td class=name>port <td class=type> Number <td>
    same as <tt>--port</tt>
<tr><td class=name>data <td class=type> path <td>
    same as <tt>--data</tt>
<tr><td class=name>heap <td class=type> Boolean <td>
    same as <tt>--heap</tt>
<tr><td class=name>profile <td class=type> Boolean <td>
    same as <tt>--profile</tt>
</table>

<!-- ======================================================================= -->

### default values ###

<table class='object-def'>
<tr><td class=name>--verbose <td class=type> Boolean <td>
    false
<tr><td class=name>--debug <td class=type> Boolean <td>
    false
<tr><td class=name>--config <td class=type> path <td>
    <tt>~/.nodprof/config.json</tt>, where <tt>~</tt> is
    the value of the <tt>USERPROFILE</tt> environment variable
    on windows
<tr><td class=name>--port <td class=type> Number <td>
    3000
<tr><td class=name>--data <td class=type> path <td>
    ~/.nodprof/data (see note on <tt>--config</tt> above)
<tr><td class=name>--serve <td class=type> Boolean <td>
    false
<tr><td class=name>--heap <td class=type> Boolean <td>
    true
<tr><td class=name>--profile <td class=type> Boolean <td>
    true
</table>

<!-- ======================================================================= -->

`nodprof` module API
--------------------------------------------------------------------------------

The `nodprof` module provides low-level support for profiling via exported
functions.  The functions return large JSON-able objects.

<!-- ======================================================================= -->

### `nodprof.profileStart()`

Start profiling.  Does nothing if profiling already started.

Returns nothing.

<!-- ======================================================================= -->

### `nodprof.profileStop()`

Stop profiling.  Does nothing if profiling already stopped.

Returns a `ProfileResults` object or `null` if profiling was not started.

<!-- ======================================================================= -->

### `nodprof.isProfiling()`

Returns true if profiling has been started, else false.

<!-- ======================================================================= -->

### `nodprof.heapSnapshot()`

Returns a `HeapSnapshotResults` object.

<!-- ======================================================================= -->

### `nodprof.middleware(config)`

Returns a function which can be used as `connect` middleware to provide the
function of the command-line `nodprof` server in your application.  The
`url` is the *directory-sh* uri to *mount* the functionality under, and defaults to
`/nodprof`.

The `config` parameter specifies a configuration object, which is the same
format as the configuration file specified above.  

Example for express:

    app.use("/nodprof/", nodprof.middleware())

<!-- ======================================================================= -->

`nodprof` object shapes
--------------------------------------------------------------------------------

For more detail on what the values in these objects *mean*, see the source at
<https://code.google.com/p/v8/source/browse/trunk/include/v8-profiler.h>

<!-- ======================================================================= -->

### `ProfilesResult` object

<table class='object-def'>
<tr><td class=name>dateStarted: <td class=type>Date        <td>
    the date the profile was started
<tr><td class=name>dateStopped: <td class=type>Date        <td>
    the date the profile was stopped
<tr><td class=name>head: <td class=type>ProfileNode <td>
    the first node in the profile
</table>

<!-- ======================================================================= -->

### `ProfilesNode` object

<table class='object-def'>
<tr><td class=name>functionName:  <td class=type>String        <td>
    the name of the function executing
<tr><td class=name>scriptName:    <td class=type>String        <td>
    the name of the script executing
<tr><td class=name>lineNumber:    <td class=type>Number        <td>
    the line number executing
<tr><td class=name>totalTime:     <td class=type>Number        <td>
    total amount of time take at this node
<tr><td class=name>selfTime:      <td class=type>Number        <td>
    the time taken by this node not including called functions
<tr><td class=name>totalSamples:  <td class=type>Number        <td>
    total number of samples retrieved
<tr><td class=name>selfSamples:   <td class=type>Number        <td>
    the numer of samples retrieved not including called functions
<tr><td class=name>children:      <td class=type>[ProfileNode] <td>
    nodes called from this node
</table>

<!-- ======================================================================= -->

### `HeapSnapshotResults` object

<table class='object-def'>
<tr><td class=name>date:          <td class=type>Date           <td>
    the date the heap snapshot was taken
<tr><td class=name>root:          <td class=type>String         <td>
    the id of the root object (a <tt><i>HeapNode</i></tt>)
<tr><td class=name>nodes:         <td class=type>Object <td>
    an object whose keys are ids and values are a <tt><i>HeapNode</i></tt>
</table>

<!-- ======================================================================= -->

### `HeapNode` object

<table class='object-def'>
<tr><td class=name>type:          <td class=type>Number <td>
    the type of node
<tr><td class=name>name:          <td class=type>String <td>
    the name of the node
<tr><td class=name>size:          <td class=type>Number <td>
    the size of the node
<tr><td class=name>edges:         <td class=type>[HeapEdge] <td>
    the edges of the node
</table>

<!-- ======================================================================= -->

### `HeapEdge` object

<table class='object-def'>
<tr><td class=name>type: <td class=name>Number <td>
    the type of edge
<tr><td class=name>name: <td class=name>String <td>
    the name of the edge
<tr><td class=name>node: <td class=name>String <td>
    the id of the node the edge points to
</table>

<!-- ======================================================================= -->

`nodprof` development
--------------------------------------------------------------------------------

If you want to hack on `nodprof`, the workflow:

1. clone the git repo
2. cd into the project directory
3. run `make watch`
4. edit the files in your flavorite editor
5. when you save files, the code will be rebuilt, and server restarted
6. generate some profiling data, view in the restarted server

Then iterate on 4, 5, and 6.
