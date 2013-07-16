// Licensed under the Apache License. See footer for details.

using namespace v8;

//------------------------------------------------------------------------------

#define PROP_SET(target, name, value) \
    (target->Set(String::NewSymbol(name), value))

#define PROP_SET_FUNCTION(target, name, value) \
    (PROP_SET(target, name, FunctionTemplate::New(value)->GetFunction()))

#define PROP_SET_STRING(target, name, value) \
    (PROP_SET(target, name, String::New(value)))

#define PROP_SET_NUMBER(target, name, value) \
    (PROP_SET(target, name, Number::New(value)))

//------------------------------------------------------------------------------
Handle<String> pointer2string(const void *pointer) {
    HandleScope scope;
    
    char pointerString[40];
    sprintf(pointerString, "%lx", (long) pointer);
    
    return scope.Close(String::New(pointerString));
}

//------------------------------------------------------------------------------
const void* string2pointer(Handle<Value> string) {
    if (!string->IsString()) {
        ThrowException(Exception::TypeError(String::New("expecting a string pointer argument")));
        return NULL;
    }
    
    String::Utf8Value pointerUtf8(string);
    const void* pointer;
    
    sscanf(*pointerUtf8, "%lx", (long *)&pointer);
    
    return pointer;
}

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