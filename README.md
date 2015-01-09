# Introduction

OrderedSet is essentially the Swift equivalent of Foundation's NSOrderedSet/NSMutableOrderedSet. It was created so Swift would have a unique, ordered collection with fast lookup performance that supported strong typing through Generics, and so we could store Swift structs and enums in it.

# Usage

OrderedSet works very much like an Array. Here are some basic examples of its usage:

```swift
var set = OrderedSet<Int>()
set.append(1)
set.contains(1) // => true
set[0] = 2
set[0] // => 2
set.insertObject(3, atIndex: 0)
set // => [3, 2]
set = [1,2,3] // OrderedSet's support array literals
set // => [1, 2, 3]
set += [3, 4] // You can concatenate any sequence type to an OrderedSet
set // => [1, 2, 3, 4] (Since 3 was already in the set it was not added again)
```

Its also recommended that you use the instance methods when possible instead of the global Swift methods for searching an OrderedSet. For example, the Swift.contains(haystack, needle) method will enumerate the OrderedSet instead of making use of the fast lookup implementation that the OrderedSet.contains(needle) method will do.

Be sure to check out the unit tests to see all the different ways to interact with an OrderedSet in action. You can also check out the sample project, which tweaks the default master/detail project to use an OrderedSet instead of an Array.

# Installation

OrderedSet is a single Swift file in the Sources directory. You can copy that file into your project, or use CocoaPods by adding the following line to your Podfile:

```ruby
pod 'OrderedSet', '1.0'
```

And then add the following import where you want to use OrderedSet:

```swift
import OrderedSet
```

# License

Copyright (c) 2015, Weebly All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. Neither the name of Weebly nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Weebly, Inc BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# CONTRIBUTING

We love to have your help to make OrderedSet better. Feel free to

* open an issue if you run into any problem.
* fork the project and submit pull request.

