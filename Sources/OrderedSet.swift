//  Copyright (c) 2014 James Richard. 
//  Distributed under the MIT License (http://opensource.org/licenses/MIT).

/// An ordered, unique collection of objects.
public struct OrderedSet<T: Hashable> {
    fileprivate var contents = [T: Index]() // Needs to have a value of Index instead of Void for fast removals
    fileprivate var sequencedContents = SequencedContents()

    fileprivate class SequencedContents {
        fileprivate var pointers = [UnsafeMutablePointer<T>]()

        func append(_ element: UnsafeMutablePointer<T>) {
            pointers.append(element)
        }

        func index(after i: Int) -> Int {
            return pointers.index(after: i)
        }

        func insert(_ element: UnsafeMutablePointer<T>, at i: Int) {
            pointers.insert(element, at: i)
        }

        var last: UnsafeMutablePointer<T>? {
            return pointers.last
        }

        @discardableResult
        func remove(at i: Int) -> UnsafeMutablePointer<T> {
            return pointers.remove(at: i)
        }

        func removeAll() {
            pointers.removeAll()
        }

        subscript(_ i: Int) -> UnsafeMutablePointer<T> {
            get { return pointers[i] }
            set { pointers[i] = newValue }
        }

        func copy() -> SequencedContents {
            let copy = SequencedContents()
            copy.pointers.reserveCapacity(pointers.count)
            for p in pointers {
                let newP = UnsafeMutablePointer<T>.allocate(capacity: 1)
                newP.initialize(from: p, count: 1)
                copy.pointers.append(newP)
            }
            return copy
        }
    }
    
    /**
     Inititalizes an empty ordered set.
     - returns:     An empty ordered set.
     */
    public init() { }
    
    /**
     Initializes a new ordered set with the order and contents
     of sequence.
     If an object appears more than once in the sequence it will only appear
     once in the ordered set, at the position of its first occurance.
     - parameter    sequence:   The sequence to initialize the ordered set with.
     - returns:                 An initialized ordered set with the contents of sequence.
     */
    public init<S: Sequence>(sequence: S) where S.Iterator.Element == T {
        for object in sequence where contents[object] == nil {
            contents[object] = contents.count
            
            let pointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
            pointer.initialize(to: object)
            sequencedContents.append(pointer)
        }
    }
    
    public init(arrayLiteral elements: T...) {
        for object in elements where contents[object] == nil {
            contents[object] = contents.count
            
            let pointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
            pointer.initialize(to: object)
            sequencedContents.append(pointer)
        }
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
    public mutating func append(_ object: T) {
        
        if let lastIndex = index(of: object) {
            remove(object)
            insert(object, at: lastIndex)
        } else {
            contents[object] = contents.count

            if !isKnownUniquelyReferenced(&sequencedContents) {
                sequencedContents = sequencedContents.copy()
            }
            let pointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
            pointer.initialize(to: object)
            sequencedContents.append(pointer)
        }
    }
    
    /**
     Appends a sequence of objects to the end of the ordered set.
     - parameter    sequence:   The sequence of objects to be appended.
     */
    public mutating func append<S: Sequence>(contentsOf sequence: S) where S.Iterator.Element == T {
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
     - returns: The former index position of the object.
     */
    @discardableResult
    public mutating func remove(_ object: T) -> Index? {
        if let index = contents[object] {
            contents[object] = nil

            if !isKnownUniquelyReferenced(&sequencedContents) {
                sequencedContents = sequencedContents.copy()
            }
            sequencedContents[index].deinitialize(count: 1)
            sequencedContents[index].deallocate()
            sequencedContents.remove(at: index)
            
            for (object, i) in contents {
                if i < index {
                    continue
                }
                
                contents[object] = i - 1
            }
            
            return index
        }
        return nil
    }
    
    /**
     Removes the given objects from the ordered set.
     - parameter    objects:    The objects to be removed.
     - returns: A collection of the former index positions of the objects. An index position is not provided for objects that were not found.
     */
    @discardableResult
    public mutating func remove<S: Sequence>(_ objects: S) -> [Index]? where S.Iterator.Element == T {
        
        var indexes = [Index]()
        objects.forEach { object in
            if let index = index(of: object) {
                indexes.append(index)
            }
        }
        
        var gen = objects.makeIterator()
        while let object: T = gen.next() {
            remove(object)
        }
        return indexes
    }
    
    /**
     Removes an object at a given index.
     This method will cause a fatal error if you attempt to move an object to an index that is out of bounds.
     - parameter    index:  The index of the object to be removed.
     */
    public mutating func removeObject(at index: Index) {
        if index < 0 || index >= count {
            fatalError("Attempting to remove an object at an index that does not exist")
        }
        
        remove(sequencedContents[index].pointee)
    }
    
    /**
     Removes all objects in the ordered set.
     */
    public mutating func removeAllObjects() {
        contents.removeAll()
        
        if !isKnownUniquelyReferenced(&sequencedContents) {
            sequencedContents = sequencedContents.copy()
        }
        for sequencedContent in sequencedContents.pointers {
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
    public mutating func swapObject(_ first: T, with second: T) {
        if let firstPosition = contents[first] {
            if let secondPosition = contents[second] {
                contents[first] = secondPosition
                contents[second] = firstPosition
                
                if !isKnownUniquelyReferenced(&sequencedContents) {
                    sequencedContents = sequencedContents.copy()
                }
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
    public mutating func moveObject(_ object: T, toIndex index: Index) {
        if index < 0 || index >= count {
            fatalError("Attempting to move an object at an index that does not exist")
        }
        
        if let position = contents[object] {
            // Return if the client attempted to move to the current index
            if position == index {
                return
            }
            
            let adjustment = position > index ? -1 : 1

            if !isKnownUniquelyReferenced(&sequencedContents) {
                sequencedContents = sequencedContents.copy()
            }
            
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
    public mutating func moveObject(at index: Index, to toIndex: Index) {
        if (index < 0 || index >= count) || (toIndex < 0 || toIndex >= count) {
            fatalError("Attempting to move an object at or to an index that does not exist")
        }
        
        moveObject(self[index], toIndex: toIndex)
    }
    
    /**
     Inserts an object at a given index, shifting all objects above it up one.
     This method will cause a fatal error if you attempt to insert the object out of bounds.
     If the object already exists in the OrderedSet, this operation is a no-op.
     - parameter    object:     The object to be inserted.
     - parameter    index:      The index to be inserted at.
     */
    public mutating func insert(_ object: T, at index: Index) {
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
    
    /**
     Inserts objects at a given index, shifting all objects above it up one.
     This method will cause a fatal error if you attempt to insert the objects out of bounds.
     If an object in objects already exists in the OrderedSet it will not be added. Objects that occur twice
     in the sequence will only be added once.
     - parameter    objects:    The objects to be inserted.
     - parameter    index:      The index to be inserted at.
     */
    public mutating func insert<S: Sequence>(_ objects: S, at index: Index) where S.Iterator.Element == T {
        if index > count || index < 0 {
            fatalError("Attempting to insert an object at an index that does not exist")
        }
        
        var addedObjectCount = 0

        if !isKnownUniquelyReferenced(&sequencedContents) {
            sequencedContents = sequencedContents.copy()
        }
        
        for object in objects where contents[object] == nil {
            let seqIdx = index + addedObjectCount
            let element = UnsafeMutablePointer<T>.allocate(capacity: 1)
            element.initialize(to: object)
            sequencedContents.insert(element, at: seqIdx)
            contents[object] = seqIdx
            addedObjectCount += 1
        }
        
        // Now we'll remove duplicates and update the shifted objects position in the contents
        // dictionary.
        for i in index + addedObjectCount..<count {
            contents[sequencedContents[i].pointee] = i
        }
    }
    
    /// Returns the last object in the set, or `nil` if the set is empty.
    public var last: T? {
        return sequencedContents.last?.pointee
    }
}

extension OrderedSet: ExpressibleByArrayLiteral { }

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
            if !isKnownUniquelyReferenced(&sequencedContents) {
                sequencedContents = sequencedContents.copy()
            }

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

public func +<T, S: Sequence> (lhs: OrderedSet<T>, rhs: S) -> OrderedSet<T> where S.Element == T {
    var joinedSet = lhs
    joinedSet.append(contentsOf: rhs)
    
    return joinedSet
}

public func +=<T, S: Sequence> (lhs: inout OrderedSet<T>, rhs: S) where S.Element == T {
    lhs.append(contentsOf: rhs)
}

public func -<T, S: Sequence> (lhs: OrderedSet<T>, rhs: S) -> OrderedSet<T> where S.Element == T {
    var purgedSet = lhs
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

extension OrderedSet: RandomAccessCollection {}
