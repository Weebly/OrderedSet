//  Copyright (c) 2014 James Richard. 
//  Distributed under the MIT License (http://opensource.org/licenses/MIT).

import Foundation

fileprivate enum Match<Index: Comparable> {
    case found(at: Index)
    case notFound(insertAt: Index)
}

extension Range where Bound == Int {
    var middle: Int? {
        guard !isEmpty else { return nil }
        return lowerBound + count / 2
    }
}

/// An ordered, unique collection of objects.
public class OrderedSet<T: Hashable> {
    fileprivate var contents = [T: Index]() // Needs to have a value of Index instead of Void for fast removals
    fileprivate var sequencedContents = [UnsafeMutablePointer<T>]()
    public typealias Comparator<A> = (A, A) -> Bool
    
    /// The predicate that determines the sort order.
    fileprivate let areInIncreasingOrder: Comparator<T>
    
    deinit {
        removeAllObjects()
    }
    
    /**
     Initializes empty.
     - parameter    areInIncreasingOrder: The comparison predicate to sort its elements.
    */
    public init(areInIncreasingOrder: @escaping Comparator<T>) {
        self.areInIncreasingOrder = areInIncreasingOrder
    }
    
    /// Initializes with a sequence that is already sorted according to the given comparison predicate.
    ///
    /// This is faster than `init(unsorted:areInIncreasingOrder:)` because the elements don't have to sorted again.
    ///
    /// - Precondition: `sorted` is sorted according to the given comparison predicate. If you violate this condition, the behavior is undefined.
    public init<S: Sequence>(sorted: S, areInIncreasingOrder: @escaping Comparator<T>) where S.Iterator.Element == T {
        for object in sorted where contents[object] == nil {
            contents[object] = contents.count
            
            let pointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
            pointer.initialize(to: object)
            sequencedContents.append(pointer)
        }
        self.areInIncreasingOrder = areInIncreasingOrder
    }
    
    /// Initializes with a sequence of unsorted elements and a comparison predicate.
    public convenience init<S: Sequence>(unsorted: S, areInIncreasingOrder: @escaping Comparator<T>) where S.Iterator.Element == T {
        let sorted = unsorted.sorted(by: areInIncreasingOrder)
        self.init(sorted: sorted, areInIncreasingOrder: areInIncreasingOrder)
    }
    
    @available(*, unavailable)
    public required init(arrayLiteral elements: T...) {
        fatalError()
    }
    
    @available(*, unavailable)
    public init<S: Sequence>(sequence: S) where S.Iterator.Element == T {
        fatalError()
    }
    
    /**
     Locate the index of an object in the ordered set.
     It is preferable to use this method over the global find() for performance reasons.
     - parameter    object: The object to find the index for.
     - returns:             The index of the object, or nil if the object is not in the ordered set.
     */
    public func index(of object: T) -> Index? {
        if let index = contents[object] {
            return index
        }
        
        return nil
    }
    
    /**
     Appends an object to the end of the ordered set.
     - parameter    object: The object to be appended.
     */
    fileprivate func append(_ object: T) {
        if let lastIndex = index(of: object) {
            remove(object)
            insert(object, at: lastIndex)
        } else {
            contents[object] = contents.count
            let pointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
            pointer.initialize(to: object)
            sequencedContents.append(pointer)
        }
    }
    
    /**
     Appends a sequence of objects to the end of the ordered set.
     - parameter    sequence:   The sequence of objects to be appended.
     */
    fileprivate func append<S: Sequence>(contentsOf sequence: S) where S.Iterator.Element == T {
        var gen = sequence.makeIterator()
        while let object: T = gen.next() {
            append(object)
        }
    }
    
    /**
     Removes an object from the ordered set.
     If the object exists in the ordered set, it will be removed.
     If it is not the last object in the ordered set, subsequent
     objects will be shifted down one position.
     - parameter    object: The object to be removed.
     */
    public func remove(_ object: T) {
        if let index = contents[object] {
            contents[object] = nil
            sequencedContents[index].deinitialize(count: 1)
            sequencedContents[index].deallocate()
            sequencedContents.remove(at: index)
            
            for (object, i) in contents {
                if i < index {
                    continue
                }
                
                contents[object] = i - 1
            }
        }
    }
    
    /**
     Removes the given objects from the ordered set.
     - parameter    objects:    The objects to be removed.
     */
    public func remove<S: Sequence>(_ objects: S) where S.Iterator.Element == T {
        var gen = objects.makeIterator()
        while let object: T = gen.next() {
            remove(object)
        }
    }
    
    /**
     Removes an object at a given index.
     This method will cause a fatal error if you attempt to move an object to an index that is out of bounds.
     - parameter    index:  The index of the object to be removed.
     */
    public func removeObject(at index: Index) {
        if index < 0 || index >= count {
            fatalError("Attempting to remove an object at an index that does not exist")
        }
        
        remove(sequencedContents[index].pointee)
    }
    
    /**
     Removes all objects in the ordered set.
     */
    public func removeAllObjects() {
        contents.removeAll()
        
        for sequencedContent in sequencedContents {
            sequencedContent.deinitialize(count: 1)
            sequencedContent.deallocate()
        }
        
        sequencedContents.removeAll()
    }
    
    /**
     Swaps two objects contained within the ordered set.
     Both objects must exist within the set, or the swap will not occur.
     - parameter    first:  The first object to be swapped.
     - parameter    second: The second object to be swapped.
     */
    public func swapObject(_ first: T, with second: T) {
        if let firstPosition = contents[first] {
            if let secondPosition = contents[second] {
                contents[first] = secondPosition
                contents[second] = firstPosition
                
                sequencedContents[firstPosition].pointee = second
                sequencedContents[secondPosition].pointee = first
            }
        }
    }
    
    /**
     Tests if the ordered set contains any objects within a sequence.
     - parameter    other:  The sequence to look for the intersection in.
     - returns:             Returns true if the sequence and set contain any equal objects, otherwise false.
     */
    public func intersects<S: Sequence>(_ other: S) -> Bool where S.Iterator.Element == T {
        var gen = other.makeIterator()
        while let object: T = gen.next() {
            if contains(object) {
                return true
            }
        }
        
        return false
    }
    
    /**
     Tests if a the ordered set is a subset of another sequence.
     - parameter    sequence:   The sequence to check.
     - returns:                 true if the sequence contains all objects contained in the receiver, otherwise false.
     */
    public func isSubset<S: Sequence>(of sequence: S) -> Bool where S.Iterator.Element == T {
        for (object, _) in contents {
            if !sequence.contains(object) {
                return false
            }
        }
        
        return true
    }
    
    /**
     Moves an object to a different index, shifting all objects in between the movement.
     This method is a no-op if the object doesn't exist in the set or the index is the
     same that the object is currently at.
     This method will cause a fatal error if you attempt to move an object to an index that is out of bounds.
     - parameter    object: The object to be moved
     - parameter    index:  The index that the object should be moved to.
     */
    public func moveObject(_ object: T, toIndex index: Index) {
        if index < 0 || index >= count {
            fatalError("Attempting to move an object at an index that does not exist")
        }
        
        if let position = contents[object] {
            // Return if the client attempted to move to the current index
            if position == index {
                return
            }
            
            let adjustment = position > index ? -1 : 1
            
            var currentIndex = position
            while currentIndex != index {
                let nextIndex = currentIndex + adjustment
                
                let firstObject = sequencedContents[currentIndex].pointee
                let secondObject = sequencedContents[nextIndex].pointee
                
                sequencedContents[currentIndex].pointee = secondObject
                sequencedContents[nextIndex].pointee = firstObject
                
                contents[firstObject] = nextIndex
                contents[secondObject] = currentIndex
                
                currentIndex += adjustment
            }
        }
    }
    
    /**
     Moves an object from one index to a different index, shifting all objects in between the movement.
     This method is a no-op if the index is the same that the object is currently at.
     This method will cause a fatal error if you attempt to move an object fro man index that is out of bounds
     or to an index that is out of bounds.
     - parameter     index:      The index of the object to be moved.
     - parameter     toIndex:    The index that the object should be moved to.
     */
    public func moveObject(at index: Index, to toIndex: Index) {
        if (index < 0 || index >= count) || (toIndex < 0 || toIndex >= count) {
            fatalError("Attempting to move an object at or to an index that does not exist")
        }
        
        moveObject(self[index], toIndex: toIndex)
    }
    
    public typealias InsertOutcome = (index: Index, didInsert: Bool)
    
    @discardableResult
    public func insert(_ object: T) -> InsertOutcome {
        switch search(for: object) {
        case let .found(at: index):
            return (index, false)
        case let .notFound(insertAt: index):
            insert(object, at: index)
            return (index, true)
        }
    }
    
    /// The index where `object` should be inserted to preserve the array's sort order.
    fileprivate func insertionIndex(for object: T) -> Index {
        switch search(for: object) {
        case let .found(at: index): return index
        case let .notFound(insertAt: index): return index
        }
    }
    
    /**
     Searches the array for `element` using binary search.
     - returns: If `element` is in the array, returns `.found(at: index)`
       where `index` is the index of the element in the array.
       If `element` is not in the array, returns `.notFound(insertAt: index)`
       where `index` is the index where the element should be inserted to
       preserve the sort order.
       If the array contains multiple elements that are equal to `element`,
       there is no guarantee which of these is found.
    
     - complexity: O(_log(n)_), where _n_ is the size of the array.
    */
    fileprivate func search(for element: T) -> Match<Index> {
        return search(for: element, in: startIndex ..< endIndex)
    }
    
    fileprivate func search(for element: T, in range: Range<Index>) -> Match<Index> {
        guard let middle = range.middle else { return .notFound(insertAt: range.upperBound) }
        switch compare(element, self[middle]) {
        case .orderedDescending:
            return search(for: element, in: index(after: middle)..<range.upperBound)
        case .orderedAscending:
            return search(for: element, in: range.lowerBound..<middle)
        case .orderedSame:
            return .found(at: middle)
        }
    }
    
    fileprivate func compare(_ lhs: T, _ rhs: T) -> Foundation.ComparisonResult {
        if areInIncreasingOrder(lhs, rhs) {
            return .orderedAscending
        } else if areInIncreasingOrder(rhs, lhs) {
            return .orderedDescending
        } else {
            // If neither element comes before the other, they _must_ be
            // equal, per the strict ordering requirement of `areInIncreasingOrder`.
            return .orderedSame
        }
    }
    
    /**
     Inserts an object at a given index, shifting all objects above it up one.
     This method will cause a fatal error if you attempt to insert the object out of bounds.
     If the object already exists in the OrderedSet, this operation is a no-op.
     - parameter    object:     The object to be inserted.
     - parameter    index:      The index to be inserted at.
     */
    fileprivate func insert(_ object: T, at index: Index) {
        if index > count || index < 0 {
            fatalError("Attempting to insert an object at an index that does not exist")
        }
        
        if contents[object] != nil {
            return
        }
        
        // Append our object, then swap them until its at the end.
        append(object)
        
        for i in (index..<count-1).reversed() {
            swapObject(self[i], with: self[i+1])
        }
    }
    
    @available(*, unavailable)
    public func insert<S: Sequence>(_ objects: S, at index: Index) where S.Iterator.Element == T {
        fatalError()
    }
    
    @discardableResult
    public func insert<S: Sequence>(_ objects: S) -> [Index] where S.Iterator.Element == T {
        var inserted = [Index]()
        for object in objects where contents[object] == nil {
            let outcome = insert(object)
            inserted.append(outcome.index)
        }
        return inserted
    }
    
    /**
     Create a copy of the given ordered set with the same content. Important: the new array has the
     same references to the previous. This is NOT a deep copy or a clone!
     */
    public func copy() -> OrderedSet<T> {
        return OrderedSet<T>(sorted: self, areInIncreasingOrder: areInIncreasingOrder)
    }
    
    /// Returns the last object in the set, or `nil` if the set is empty.
    public var last: T? {
        return sequencedContents.last?.pointee
    }
}

extension OrderedSet where T: Comparable {
    
    /// Initializes empty sorted. Uses `<` as the comparison predicate.
    public convenience init() {
        self.init(areInIncreasingOrder: <)
    }
    
    /**
     Initializes with a sequence that is already sorted according to the `<` comparison predicate. Uses `<` as the comparison predicate.
     This is faster than `init(unsorted:)` because the elements don't have to sorted again.
     - precondition: `sorted` is sorted according to the `<` predicate. If you violate this condition, the behavior is undefined.
    */
    public convenience init<S: Sequence>(sorted: S) where S.Iterator.Element == T {
        self.init(sorted: sorted, areInIncreasingOrder: <)
    }
    
    /// Initializes with a sequence of unsorted elements. Uses `<` as the comparison predicate.
    public convenience init<S: Sequence>(unsorted: S) where S.Iterator.Element == T {
        self.init(unsorted: unsorted, areInIncreasingOrder: <)
    }
}

extension OrderedSet where T: Comparable {}

extension OrderedSet {
    
    public var count: Int {
        return contents.count
    }
    
    public var isEmpty: Bool {
        return count == 0
    }
    
    public var first: T? {
        guard count > 0 else { return nil }
        return sequencedContents[0].pointee
    }
    
    public func index(after index: Int) -> Int {
        return sequencedContents.index(after: index)
    }
    
    public typealias Index = Int
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return contents.count
    }
    
    public subscript(index: Index) -> T {
        get {
            return sequencedContents[index].pointee
        }
        
        set {
            let previousCount = contents.count
            contents[sequencedContents[index].pointee] = nil
            contents[newValue] = index
            
            // If the count is reduced we used an existing value, and need to sync up sequencedContents
            if contents.count == previousCount {
                sequencedContents[index].pointee = newValue
            } else {
                sequencedContents[index].deinitialize(count: 1)
                sequencedContents[index].deallocate()
                sequencedContents.remove(at: index)
            }
        }
    }
    
}

extension  OrderedSet: Sequence {
    public typealias Iterator = OrderedSetGenerator<T>
    
    public func makeIterator() -> Iterator {
        return OrderedSetGenerator(set: self)
    }
}

public struct OrderedSetGenerator<T: Hashable>: IteratorProtocol {
    public typealias Element = T
    private var generator: IndexingIterator<[UnsafeMutablePointer<T>]>
    
    public init(set: OrderedSet<T>) {
        generator = set.sequencedContents.makeIterator()
    }
    
    public mutating func next() -> Element? {
        return generator.next()?.pointee
    }
}

extension OrderedSetGenerator where T: Comparable {}

public func +<T, S: Sequence> (lhs: OrderedSet<T>, rhs: S) -> OrderedSet<T> where S.Element == T {
    let joinedSet = lhs.copy()
    joinedSet.append(contentsOf: rhs)
    
    return joinedSet
}

public func +=<T, S: Sequence> (lhs: inout OrderedSet<T>, rhs: S) where S.Element == T {
    lhs.append(contentsOf: rhs)
}

public func -<T, S: Sequence> (lhs: OrderedSet<T>, rhs: S) -> OrderedSet<T> where S.Element == T {
    let purgedSet = lhs.copy()
    purgedSet.remove(rhs)
    
    return purgedSet
}

public func -=<T, S: Sequence> (lhs: inout OrderedSet<T>, rhs: S) where S.Element == T {
    lhs.remove(rhs)
}

extension OrderedSet: Equatable { }

public func ==<T> (lhs: OrderedSet<T>, rhs: OrderedSet<T>) -> Bool {
    if lhs.count != rhs.count {
        return false
    }
    
    for object in lhs where lhs.contents[object] != rhs.contents[object] {
        return false
    }
    
    return true
}

extension OrderedSet: CustomStringConvertible {
    public var description: String {
        let children = map({ "\($0)" }).joined(separator: ", ")
        return "OrderedSet (\(count) object(s)): [\(children)]"
    }
}
