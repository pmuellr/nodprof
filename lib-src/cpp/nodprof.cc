// Licensed under the Apache License. See footer for details.

#include <node.h>
#include <v8.h>
#include <v8-profiler.h>

#include "nodprof.h"

using namespace v8;

//------------------------------------------------------------------------------

static Handle<Object> getProfileNodeTree(const CpuProfileNode* node);

static Handle<String> getHeapNodeObject(Handle<Object> nodes, const HeapGraphNode* node);
static Handle<Value>  getHeapEdgeObject(Handle<Object> nodes, const HeapGraphEdge* edge);

//------------------------------------------------------------------------------

Handle<Value> NodProfProfilerStart(const Arguments& args) {
    HandleScope scope;
    
//    printf("in native NodProfProfilerStart()\n");
    
    CpuProfiler::StartProfiling(String::New(""));
    
    return scope.Close(Undefined());
}

//------------------------------------------------------------------------------

Handle<Value> NodProfProfilerStop(const Arguments& args) {
    HandleScope scope;

//    printf("in native NodProfProfilerStop()\n");

    CpuProfile* profile = (CpuProfile*)CpuProfiler::StopProfiling(
        String::New(""), Handle<Value>(NULL)
    );

    Local<Object> result = Object::New();
    
    //PROP_SET(result, "tail",  getProfileNodeTree(profile->GetBottomUpRoot()));
    PROP_SET(result, "head",  getProfileNodeTree(profile->GetTopDownRoot() ));
    
    profile->Delete();

    return scope.Close(result);
}

//------------------------------------------------------------------------------
Handle<Object> getProfileNodeTree(const CpuProfileNode* node) {
    HandleScope scope;
    
    Local<Object> nodeObject = Object::New();
    Local<Array>  children = Array::New();
    
    PROP_SET(        nodeObject, "functionName", node->GetFunctionName());
    PROP_SET(        nodeObject, "scriptName",   node->GetScriptResourceName());
    PROP_SET_NUMBER( nodeObject, "lineNumber",   node->GetLineNumber());
    PROP_SET_NUMBER( nodeObject, "totalTime",    node->GetTotalTime());
    PROP_SET_NUMBER( nodeObject, "selfTime",     node->GetSelfTime());
    PROP_SET_NUMBER( nodeObject, "totalSamples", node->GetTotalSamplesCount());
    PROP_SET_NUMBER( nodeObject, "selfSamples",  node->GetSelfSamplesCount());
    PROP_SET(        nodeObject, "children",     children);

    int childrenCount = node->GetChildrenCount();
    
    for (int i=0; i<childrenCount; i++) {
        const CpuProfileNode* child = node->GetChild(i);
        children->Set(i, getProfileNodeTree(child));
    }
    
    return scope.Close(nodeObject);
}

//------------------------------------------------------------------------------

Handle<Value> NodProfHeapSnapShotTake(const Arguments& args) {
    HandleScope   scope;

//    printf("in  native NodProfHeapSnapShotTake()\n");

    HeapSnapshot* snapShot = (HeapSnapshot*) HeapProfiler::TakeSnapshot(String::New(""));

    Local<Object>        result = Object::New();
    Local<Object>        nodes  = Object::New();
    const HeapGraphNode* root   = snapShot->GetRoot();
    
    getHeapNodeObject(nodes, root);
    
    PROP_SET(result, "root",  getHeapNodeObject(nodes, snapShot->GetRoot()));
    PROP_SET(result, "nodes", nodes);

    snapShot->Delete();
    
    return scope.Close(result);
}

//------------------------------------------------------------------------------

Handle<String> getHeapNodeObject(Handle<Object> nodes, const HeapGraphNode* node) {
    HandleScope   scope;
    
    Handle<String> stringPtr = pointer2string(node);
    
    // String::Utf8Value stringUtf8(stringPtr);
    // printf("processing node %s\n", *stringUtf8);

    if (nodes->Has(stringPtr)) {
        // printf("   already handled!\n");
        return scope.Close(stringPtr);
    }

    Local<Object> result = Object::New();
    nodes->Set(stringPtr, result);
    
    Local<Array> children = Array::New();
    
    PROP_SET_NUMBER( result, "type",  node->GetType());
    PROP_SET(        result, "name",  node->GetName());
    PROP_SET_NUMBER( result, "size",  node->GetSelfSize());
    PROP_SET(        result, "edges", children);
    
    int count = node->GetChildrenCount();
    
    for (int i=0; i<count; i++) {
        const HeapGraphEdge* edge = node->GetChild(i);
        
        children->Set(i, getHeapEdgeObject(nodes, edge));
    }
    
    return scope.Close(stringPtr);
}

//------------------------------------------------------------------------------

Handle<Value> getHeapEdgeObject(Handle<Object> nodes, const HeapGraphEdge* edge) {
    HandleScope   scope;

    // String::Utf8Value stringUtf8(pointer2string(edge));
    // printf("processing edge %s\n", *stringUtf8);

    Local<Object> result = Object::New();

    const HeapGraphNode* toNode = edge->GetToNode();
    
    PROP_SET_NUMBER( result, "type", edge->GetType());
    PROP_SET(        result, "name", edge->GetName());
    PROP_SET(        result, "node", getHeapNodeObject(nodes, toNode));
    
    return scope.Close(result);
}

//------------------------------------------------------------------------------

void init(Handle<Object> target) {
    PROP_SET_FUNCTION(target, "profilerStart",       NodProfProfilerStart);    
    PROP_SET_FUNCTION(target, "profilerStop",        NodProfProfilerStop);    
    PROP_SET_FUNCTION(target, "heapSnapShotTake",    NodProfHeapSnapShotTake);
}

//------------------------------------------------------------------------------

NODE_MODULE(nodprof_natives, init)

/*
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
*/