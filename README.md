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
set.insert(3, at: 0)
set // => [3, 2]
set = [1,2,3] // OrderedSet's support array literals
set // => [1, 2, 3]
set += [3, 4] // You can concatenate any sequence type to an OrderedSet
set // => [1, 2, 3, 4] (Since 3 was already in the set it was not added again)
```

Its also recommended that you use the instance methods when possible instead of the global Swift methods for searching an OrderedSet. For example, the Swift.contains(haystack, needle) method will enumerate the OrderedSet instead of making use of the fast lookup implementation that the OrderedSet.contains(needle) method will do.

Be sure to check out the unit tests to see all the different ways to interact with an OrderedSet in action. You can also check out the sample project, which tweaks the default master/detail project to use an OrderedSet instead of an Array.

# Installation

OrderedSet is a single Swift file in the Sources directory. You can copy that file into your project, or use via CocoaPods by adding the following line to your Podfile:

```ruby
pod 'OrderedSet', '3.0'
```

or use via Carthage by adding

```
github "Weebly/OrderedSet"
```

to your Cartfile and embedding the OrderedSet.framework in your app.

And then add the following import where you want to use OrderedSet:

```swift
import OrderedSet
```

*For Swift 3*:

Using CocoaPods:
```ruby
pod 'OrderedSet', :git => 'https://github.com/Weebly/OrderedSet.git', :tag => 'swift-3'
```

Using Carthage:
```
github "Weebly/OrderedSet" "swift-3"
```

# License

OrderedSet is available under the MIT license. See the LICENSE file for more info.

# CONTRIBUTING

We love to have your help to make OrderedSet better. Feel free to

* open an issue if you run into any problem.
* fork the project and submit pull request.

