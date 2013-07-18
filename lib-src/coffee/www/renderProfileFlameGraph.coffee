# Licensed under the Apache License. See footer for details.

d3 = require "d3"

#-------------------------------------------------------------------------------
exports.render = (sel, profile) ->
    pruneIdle profile.head
    root = removeEmptyChildren(profile.head)

    partitionize(root)

    partition = d3.layout.partition()
        .value( (d) -> d.selfTime )
        .sort(null)

    nodes = partition.nodes(root)
    depth = Math.max.apply(null, nodes.map( (d) -> d.depth ))

    d3.selectAll("#{sel} svg").remove()

    boxHeight = 40
    fontSize  = 15

    g = null
    w = 1000
    h = boxHeight * depth
    x = d3.scale.linear().range([0, w])
    y = d3.scale.linear().range([0, h])

    profClick = (d) ->
        if (!d.children) then return

        d3.event.stopPropagation()

        scale  = w / x(d.dx)
        offset = - x(d.x) * scale

        t = g.transition()
            .duration(if d3.event.altKey then 7500 else 750)
            .attr("transform", (d) ->
                "translate(" +
                    (offset + scale * x(d.x)) + "," +
                    (h - y(d.y) - boxHeight) +
                ")"
            )

        t.select("rect")
            .attr("width",  (d) -> scale * x(d.dx) )

        t.select(".clippath").select("rect")
            .attr("width",  (d) -> scale * x(d.dx) )

        t.select("text")
            .attr("text-anchor", "middle")
            .attr("x", (d) -> scale * x(d.dx)/2)

    chart = d3.select(sel)
        .style("zzz-width",  w + "px")
        .style("zzz-height", h + "px")

    svg = chart.append("svg:svg")
        .attr("width",  w)
        .attr("height", h)
        .attr("viewBox", "0 0 #{w} #{h}")
        .attr("zzz-preserveAspectRatio", "xMidYMin")

    g = svg.selectAll("g")
        .data(nodes)
    .enter().append("svg:g")
        .attr("transform", (d) -> 
            "translate(" + x(d.x) + "," + (h - y(d.y) - boxHeight) + ")"
        )
        .on("click",     profClick)
        .on("mouseover", updateIdentifiedNode)

    g.append("svg:title").text(nodeDescription)

    g.append("svg:rect")
        .attr("width",  (d) -> x(d.dx) )
        .attr("height", (d) -> y(d.dy) )
        .attr("class",  (d) -> "parent" )
        .style("opacity", (d) ->
            if (!d.parent) then return 1
            if (d.parent && d.parent.totalTime >= 0 && d.totalTime >= 0) 
                value = 0.3 + (0.7 * (d.totalTime / d.parent.totalTime))
                return value
            
        )
        .classed("invisible", (d) -> d.invisible )

    g.append("svg:clipPath")
        .property("id", (d,i) -> "text-clip-path-" + i)
        .classed("clippath", true)
    .append("svg:rect")
        .attr("width",  (d) -> x(d.dx) )
        .attr("height", (d) -> y(d.dy) )

    g.append("svg:text")
        .attr("x", (d) -> x(d.dx)/2)
        .attr("y", h / depth - fontSize)
        .attr("text-anchor", "middle")
        .attr("font-size", fontSize)
        .attr("font-family", "Verdana")
        .style("clip-path", (d,i) ->
            "url(#text-clip-path-" + i + ")"
        )
        .text((d) ->
            if (d.invisible) then return ""
            func = d.functionName || "<anon>"
            return func + "()"
        )

    d3.select(window)
        .on("click", -> profClick(root) )


#-------------------------------------------------------------------------------
pruneIdle = (node, parentNode={}) ->

    if node.functionName is "(program)"
        if parentNode.functionName is "(root)"
            # console.log ""
            # console.log "before:"
            # dumpNode parentNode
            # dumpNode node

            parentNode.totalTime    -= node.selfTime
            parentNode.totalSamples -= node.selfSamples

            node.totalTime    -= node.selfTime
            node.selfTime      = 0
            node.totalSamples -= node.selfSamples
            node.selfSamples   = 0

            # console.log ""
            # console.log "after:"
            # dumpNode parentNode
            # dumpNode node
            
            return

    for child in node.children
        pruneIdle child, node

    return

#-------------------------------------------------------------------------------
dumpNode = (node) ->
    console.log "node: #{node.functionName}"
    console.log "    selfTime:     #{node.selfTime    }"
    console.log "    totalTime:    #{node.totalTime   }"
    console.log "    selfSamples:  #{node.selfSamples }"
    console.log "    totalSamples: #{node.totalSamples}"
    return

#-------------------------------------------------------------------------------
removeEmptyChildren = (parent) ->
    if (!parent.children) then return
    if (!parent.children.length) 
        delete parent.children
        return
    

    for child in parent.children
        removeEmptyChildren(child)

    return parent

#-------------------------------------------------------------------------------
# typical profiling data - selfTime/totalTime values on all nodes in a tree -
# is not how a partition tree in d3 is specified.  In d3, a partition only
# considers "values" on leaf nodes, and not non-leaf nodes.  So, for d3,
# we'll use "selfTime" as the value, and for every non-leaf node, we'll add
# a new child leaf node with the "selfTime" value.  Kinda wonky, but the
# data model works.  Maybe color those synthethic nodes transparent?
#-------------------------------------------------------------------------------
partitionize = (node) ->
    if (!node.children) then return
    if (!node.children.length) then return

    for child in node.children
        partitionize(child)

    node.children.push
        selfTime:  node.selfTime
        invisible: true

#-------------------------------------------------------------------------------
nodeDescription = (node) ->
    if (node.invisible) then return

    func = node.functionName
    file = node.scriptName
    line = node.lineNumber

    if (!func || func == "")
        func = "<anonymous>"
    else
        func += "()"

    if (!file || file == "") then file = "<no file>"
    if (!line)               then line = ""

    message = func + "\n" +
        "   file: " + file + ":" + line + "\n" +
        "   selfTime:  " + node.selfTime      + "\n" +
        "   totalTime: " + node.totalTime

    return message

#-------------------------------------------------------------------------------
updateIdentifiedNode = (node) ->
    if (node.invisible) then return

    func = node.functionName
    file = node.scriptName
    line = node.lineNumber

    if (!func || func == "")
        func = "<anonymous>"
    else
        func += "()"

    if (!file || file == "") then file = "<no file>"
    if (!line)               then line = ""

    message = func + " in " + file + ":" + line + "\n" +
        "   called:    " + node.numberOfCalls + " times\n" +
        "   selfTime:  " + node.selfTime      + "\n" +
        "   totalTime: " + node.totalTime

    # d3.select$("#identified-node").text(message)


#-------------------------------------------------------------------------------
# Copyright 2013 I.B.M.
# 
# Licensed under the Apache License, Version 2.0 (the "License")
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
