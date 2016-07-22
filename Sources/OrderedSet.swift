//
//  OrderedSet.swift
//  Weebly
//
//  Created by James Richard on 10/22/14.
//  Copyright (c) 2014 Weebly.
//

/// An ordered, unique collection of objects.
public class OrderedSet<T: Hashable> : ArrayLiteralConvertible {
    private var contents = [T: Index]() // Needs to have a value of Index instead of Void for fast removals
    private var sequencedContents = Array<UnsafeMutablePointer<T>>()
    
    /**
     Inititalizes an empty ordered set.
     :return: An empty ordered set.
     */
    public init() { }
    
    deinit{
        removeAllObjects()
    }
    
    /**
     Initializes a new ordered set with the order and contents
     of sequence.
     If an object appears more than once in the sequence it will only appear
     once in the ordered set, at the position of its first occurance.
     :param: sequence The sequence to initialize the ordered set with.
     :return: An initialized ordered set with the contents of sequence.
     */
    public init<S: SequenceType where S.Generator.Element == T>(sequence: S) {
        for object in sequence {
            if contents[object] == nil {
                contents[object] = contents.count
                
                let pointer = UnsafeMutablePointer<T>.alloc(1)
                pointer.initialize(object)
                sequencedContents.append(pointer)
            }
        }
    }
    
    // FIXME: putting this in an ArrayLiteralConvertible extension is now crashing the compiler, move it back when fixed
    public required init(arrayLiteral elements: T...) {
        for object in elements {
            if contents[object] == nil {
                contents[object] = contents.count
                
                let pointer = UnsafeMutablePointer<T>.alloc(1)
                pointer.initialize(object)
                sequencedContents.append(pointer)
            }
        }
    }
    
    
    /**
     Locate the index of an object in the ordered set.
     It is preferable to use this method over the global find() for performance reasons.
     :param:     object      The object to find the index for.
     :return:    The index of the object, or nil if the object is not in the ordered set.
     */
    public func indexOfObject(object: T) -> Index? {
        if let index = contents[object] {
            return index
        }
        
        return nil
    }
    
    /**
     Appends an object to the end of the ordered set.
     :param:     object  The object to be appended.
     */
    public func append(object: T) {
        
        if let lastIndex = indexOfObject(object) {
            remove(object)
            insertObject(object, atIndex: lastIndex)
        } else {
            contents[object] = contents.count
            let pointer = UnsafeMutablePointer<T>.alloc(1)
            pointer.initialize(object)
            sequencedContents.append(pointer)
        }
    }
    
    /**
     Appends a sequence of objects to the end of the ordered set.
     :param:     objects  The objects to be appended.
     */
    public func appendObjects<S: SequenceType where S.Generator.Element == T>(objects: S) {
        var gen = objects.generate()
        while let object: T = gen.next() {
            append(object)
        }
    }
    
    /**
     Removes an object from the ordered set.
     If the object exists in the ordered set, it will be removed.
     If it is not the last object in the ordered set, subsequent
     objects will be shifted down one position.
     :param:     object  The object to be removed.
     */
    public func remove(object: T) {
        if let index = contents[object] {
            contents[object] = nil
            sequencedContents[index].dealloc(1)
            sequencedContents.removeAtIndex(index)
            
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
     :param:     objects     The objects to be removed.
     */
    public func removeObjects<S: SequenceType where S.Generator.Element == T>(objects: S) {
        var gen = objects.generate()
        while let object: T = gen.next() {
            remove(object)
        }
    }
    
    /**
     Removes an object at a given index.
     This method will cause a fatal error if you attempt to move an object to an index that is out of bounds.
     :param:     index       The index of the object to be removed.
     */
    public func removeObjectAtIndex(index: Index) {
        if index < 0 || index >= count {
            fatalError("Attempting to remove an object at an index that does not exist")
        }
        
        remove(sequencedContents[index].memory)
    }
    
    /**
     Removes all objects in the ordered set.
     */
    public func removeAllObjects() {
        contents.removeAll()
        
        for sequencedContent in sequencedContents {
            sequencedContent.dealloc(1)
        }
        
        sequencedContents.removeAll()
    }
    
    /**
     Swaps two objects contained within the ordered set.
     Both objects must exist within the set, or the swap will not occur.
     :param:     first   The first object to be swapped.
     :param:     second  The second object to be swapped.
     */
    public func swapObject(first: T, withObject second: T) {
        if let firstPosition = contents[first] {
            if let secondPosition = contents[second] {
                contents[first] = secondPosition
                contents[second] = firstPosition
                
                sequencedContents[firstPosition].memory = second
                sequencedContents[secondPosition].memory = first
            }
        }
    }
    
    /**
     Tests if the ordered set contains any objects within a sequence.
     :param:     sequence    The sequence to look for the intersection in.
     :return:    Returns true if the sequence and set contain any equal objects, otherwise false.
     */
    public func intersectsSequence<S: SequenceType where S.Generator.Element == T>(sequence: S) -> Bool {
        var gen = sequence.generate()
        while let object: T = gen.next() {
            if contains(object) {
                return true
            }
        }
        
        return false
    }
    
    /**
     Tests if a the ordered set is a subset of another sequence.
     :param:     sequence    The sequence to check.
     :return:    true if the sequence contains all objects contained in the receiver, otherwise false.
     */
    public func isSubsetOfSequence<S: SequenceType where S.Generator.Element == T>(sequence: S) -> Bool {
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
     :param:     object  The object to be moved
     :param:     index   The index that the object should be moved to.
     */
    public func moveObject(object: T, toIndex index: Index) {
        if index < 0 || index >= count {
            fatalError("Attempting to move an object at an index that does not exist")
        }
        
        if let position = contents[object] {
            // Return if the client attempted to move to the current index
            if position == index {
                return
            }
            
            let adjustment = position < index ? -1 : 1
            let range = index < position ? index..<position : position..<index
            for (object, i) in contents {
                // Skip items not within the range of movement
                if i < range.startIndex || i > range.endIndex || i == position {
                    continue
                }
                
                let originalIndex = contents[object]!
                let newIndex = i + adjustment
                
                let firstObject = sequencedContents[originalIndex].memory
                let secondObject = sequencedContents[newIndex].memory
                
                sequencedContents[originalIndex].memory = secondObject
                sequencedContents[newIndex].memory = firstObject
                
                contents[object] = newIndex
            }
            
            contents[object] = index
        }
    }
    
    /**
     Moves an object from one index to a different index, shifting all objects in between the movement.
     This method is a no-op if the index is the same that the object is currently at.
     This method will cause a fatal error if you attempt to move an object fro man index that is out of bounds
     or to an index that is out of bounds.
     :param:     index   The index of the object to be moved.
     :param:     toIndex   The index that the object should be moved to.
     */
    public func moveObjectAtIndex(index: Index, toIndex: Index) {
        if ((index < 0 || index >= count) || (toIndex < 0 || toIndex >= count)) {
            fatalError("Attempting to move an object at or to an index that does not exist")
        }
        
        moveObject(self[index], toIndex: toIndex)
    }
    
    /**
     Inserts an object at a given index, shifting all objects above it up one.
     This method will cause a fatal error if you attempt to insert the object out of bounds.
     If the object already exists in the OrderedSet, this operation is a no-op.
     :param:     object      The object to be inserted.
     :param:     atIndex     The index to be inserted at.
     */
    public func insertObject(object: T, atIndex index: Index) {
        if index > count || index < 0 {
            fatalError("Attempting to insert an object at an index that does not exist")
        }
        
        if contents[object] != nil {
            return
        }
        
        // Append our object, then swap them until its at the end.
        append(object)
        
        for i in (index..<count-1).reverse() {
            swapObject(self[i], withObject: self[i+1])
        }
    }
    
    /**
     Inserts objects at a given index, shifting all objects above it up one.
     This method will cause a fatal error if you attempt to insert the objects out of bounds.
     If an object in objects already exists in the OrderedSet it will not be added. Objects that occur twice
     in the sequence will only be added once.
     :param:     objects      The objects to be inserted.
     :param:     atIndex      The index to be inserted at.
     */
    public func insertObjects<S: SequenceType where S.Generator.Element == T>(objects: S, atIndex index: Index) {
        if index > count || index < 0 {
            fatalError("Attempting to insert an object at an index that does not exist")
        }
        
        var addedObjectCount = 0
        // FIXME: For some reason, Swift gives the error "Cannot convert the expression's type 'S' to type 'S'" with a regular for-in, so this is a hack to fix that.
        var gen = objects.generate()
        
        // This loop will make use of our sequncedContents array to update the contents dictionary's
        // values. During this loop there will be duplicate values in the dictionary.
        while let object: T = gen.next() {
            if contents[object] == nil {
                let seqIdx = index + addedObjectCount
                let element = UnsafeMutablePointer<T>.alloc(1)
                element.initialize(object)
                sequencedContents.insert(element, atIndex: seqIdx)
                contents[object] = seqIdx
                addedObjectCount += 1
            }
        }
        
        // Now we'll remove duplicates and update the shifted objects position in the contents
        // dictionary.
        for i in index + addedObjectCount..<count {
            contents[sequencedContents[i].memory] = i
        }
    }
}

extension OrderedSet where T: Comparable {}

extension OrderedSet: MutableCollectionType {
    public typealias Index = Int
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return contents.count
    }
    
    public subscript(index: Index) -> T {
        get {
            return sequencedContents[index].memory
        }
        
        set {
            contents[sequencedContents[index].memory] = nil
            contents[newValue] = index
            sequencedContents[index].memory = newValue
        }
    }
}

extension  OrderedSet: SequenceType {
    public typealias Generator = OrderedSetGenerator<T>
    
    public func generate() -> Generator {
        return OrderedSetGenerator(set: self)
    }
}

public struct OrderedSetGenerator<T: Hashable>: GeneratorType {
    public typealias Element = T
    private var generator: IndexingGenerator<Array<UnsafeMutablePointer<T>>>
    
    public init(set: OrderedSet<T>) {
        generator = set.sequencedContents.generate()
    }
    
    public mutating func next() -> Element? {
        return generator.next()?.memory
    }
}

extension OrderedSetGenerator where T: Comparable {}

public func +<T: Hashable, S: SequenceType where S.Generator.Element == T> (lhs: OrderedSet<T>, rhs: S) -> OrderedSet<T> {
    let joinedSet = lhs
    joinedSet.appendObjects(rhs)
    
    return joinedSet
}

public func +=<T: Hashable, S: SequenceType where S.Generator.Element == T> (inout lhs: OrderedSet<T>, rhs: S) {
    lhs.appendObjects(rhs)
}

public func -<T: Hashable, S: SequenceType where S.Generator.Element == T> (lhs: OrderedSet<T>, rhs: S) -> OrderedSet<T> {
    let purgedSet = lhs
    purgedSet.removeObjects(rhs)
    
    return purgedSet
}

public func -=<T: Hashable, S: SequenceType where S.Generator.Element == T> (inout lhs: OrderedSet<T>, rhs: S) {
    lhs.removeObjects(rhs)
}

extension OrderedSet: Equatable { }

public func ==<T: Hashable> (lhs: OrderedSet<T>, rhs: OrderedSet<T>) -> Bool {
    if lhs.count != rhs.count {
        return false
    }
    
    for object in lhs {
        if lhs.contents[object] != rhs.contents[object] {
            return false
        }
    }
    
    return true
}

extension OrderedSet: CustomStringConvertible {
    public var description: String {
        let children = map({ "\($0)" }).joinWithSeparator(", ")
        return "OrderedSet (\(count) object(s)): [\(children)]"
    }
}
