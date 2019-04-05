//
//  OrderedSet_Tests.swift
//  Weebly
//
//  Created by James Richard on 10/22/14.
//  Copyright (c) 2014 Weebly. All rights reserved.
//

import XCTest
import OrderedSet

class OrderedSet_Tests: XCTestCase {

	//TODO: add tests for more Swift 2.x default SequenceType and Collection implementations
    
    // MARK: Count
    
    func testCount_withoutObjects_is0() {
        let subject = OrderedSet<String>()
        XCTAssertEqual(subject.count, 0)
    }
    
    // MARK: isEmpty
    
    func testIsEmpty_whenEmpty_isTrue() {
        let subject = OrderedSet<String>()
        XCTAssertTrue(subject.isEmpty)
    }
    
    func testIsEmpty_whenEmptyNotEmpty_isFalse() {
        let subject = OrderedSet<String>(sequence: ["One"])
        XCTAssertFalse(subject.isEmpty)
    }

    // MARK: Append
    
    func testAppend_increasesCount() {
        var subject = OrderedSet<String>()
        subject.append("Test")
        XCTAssertEqual(subject.count, 1)
    }

    func testAppend_withSameObjectTwice_keepsCountAs1() {
        var subject = OrderedSet<String>()
        subject.append("Test")
        subject.append("Test")
        XCTAssertEqual(subject.count, 1)
    }
    
    // MARK: Subscript
    
    func testObjectSubscript_returnsCorrectObject() {
        var subject = OrderedSet<String>()
        subject.append("Test")
        XCTAssert(subject[0] == "Test")
    }
    
    func testSubscriptInsertion_replacesObject() {
        var subject = OrderedSet<String>(sequence: ["One", "Two", "Three"])
        subject[1] = "wat"
        XCTAssertEqual(subject.count, 3)
        XCTAssert(subject[0] == "One")
        XCTAssert(subject[1] == "wat")
        XCTAssert(subject[2] == "Three")
    }
    
    func testSubscriptSetting_iteratesCorrectly() {
        var subject: OrderedSet<Int> = [0, 1, 2]
        subject[1] = 0
        var contents = [Int]()
        for i in subject {
            contents.append(i)
        }
        
        XCTAssertEqual(contents.count, 2)
        XCTAssertEqual(contents[0], 0)
        XCTAssertEqual(contents[1], 2)
    }
    
    // MARK: Contains

    func testContains_whenObjectIsContained_isTrue() {
        var subject = OrderedSet<String>()
        subject.append("Test")
        XCTAssertTrue(subject.contains("Test"))
    }

    func testContains_whenObjectIsNotContained_isFalse() {
        let subject = OrderedSet<String>()
        XCTAssertFalse(subject.contains("Test"))
    }
    
    // MARK: Enumeration
    
    func testEnumeration_enumeratesAllObjectsInOrder() {
        let subject = OrderedSet<String>(sequence: ["One", "Two", "Three"])
        var enumeratedObjects = [String]()
        for object in subject {
            enumeratedObjects.append(object)
        }
        
        let expected = ["One", "Two", "Three"]
        
        XCTAssertEqual(enumeratedObjects, expected)
    }

    // MARK: Init With Sequence
    
    func testInitWithSequence_withDuplicates_onlyCountsThemOnce() {
        let subject = OrderedSet<String>(sequence: ["One", "Two", "Two", "Four"])
        XCTAssertEqual(subject.count, 3)
    }
    
    func testInitWithSequence_withDuplicates_doesntChangeIndexAfterFirst() {
        let subject = OrderedSet<String>(sequence: ["One", "Two", "Two", "Four"])
        XCTAssert(subject[0] == "One")
        XCTAssert(subject[1] == "Two")
        XCTAssert(subject[2] == "Four")
    }

    // MARK: Init With Array Literal
    
    func testInitializingWithArrayLiteral_includesItemsInOrder() {
        let subject: OrderedSet<String> = ["One", "Two"]
        var enumeratedObjects = [String]()
        for object in subject {
            enumeratedObjects.append(object)
        }
        
        let expected = ["One", "Two"]
        
        XCTAssertEqual(enumeratedObjects, expected)
    }
    
    // MARK: Index Of Object
    
    func testIndexOfObject_whenObjectExists_isCorrectIndex() {
        let subject = OrderedSet<String>(sequence: ["One", "Two", "Three"])
        XCTAssert(subject.index(of: "Three") == 2)
    }
    
    func testIndexOfObject_whenObjectDoesntExist_isNil() {
        let subject = OrderedSet<String>(sequence: ["One", "Two", "Three"])
        XCTAssertNil(subject.index(of: "Four"))
    }
    
    // MARK: Remove
    
    func testRemove_whenObjectExists_reducesCount() {
        var subject = OrderedSet<String>(sequence: ["One", "Two", "Three"])
        subject.remove("Two")
        XCTAssertEqual(subject.count, 2)
    }
    
    func testRemove_whenObjectDoesntExist_doesntChangeCount() {
        var subject = OrderedSet<String>(sequence: ["One", "Two", "Three"])
        subject.remove("Twoz")
        XCTAssertEqual(subject.count, 3)
    }
    
    func testRemove_whenObjectIsNotLast_updatesOrdering() {
        var subject = OrderedSet<String>(sequence: ["One", "Two", "Three", "Four"])
        subject.remove("Two")
        XCTAssert(subject[0] == "One")
        XCTAssert(subject[1] == "Three")
        XCTAssert(subject[2] == "Four")
    }
    
    // MARK: Remove Objects
    
    func testRemoveObjects_removesPassedInObjects() {
        var subject = OrderedSet<String>(sequence: ["One", "Two", "Three", "Four"])
        subject.remove(["Two", "Four"])
        let expected: OrderedSet<String> = ["One", "Three"]
        XCTAssertEqual(subject, expected)
    }
    
    func testRemoveObjects_returnsCollectionOfCorrectIndexPositions() {
        var subject = OrderedSet<String>(sequence: ["One", "Two", "Three", "Four"])
        let indexes = subject.remove(["Two", "Four"])
        XCTAssertEqual(indexes, [1, 3])
    }
    
    func testRemoveObjects__whenAnObjectDoesntExist_returnsCollectionOfCorrectIndexPositions() {
        var subject = OrderedSet<String>(sequence: ["One", "Two", "Three", "Four"])
        let indexes = subject.remove(["Two", "Three", "Six"])
        XCTAssertEqual(indexes, [1, 2])
    }
    
    // MARK: Remove Object At Index
    
    func testRemoveObjectAtIndex_removesTheObjectAtIndex() {
        var subject = OrderedSet<String>(sequence: ["One", "Two", "Three", "Four"])
        subject.removeObject(at: 1)
        let expected: OrderedSet<String> = ["One", "Three", "Four"]
        XCTAssertEqual(subject, expected)
    }
    
    // MARK: Index of removed Object
    
    func testRemoveObject_returnsCorrectIndex() {
        var subject = OrderedSet<String>(sequence: ["One", "Two", "Three"])
        let index = subject.remove("Two")
        XCTAssertEqual(index, 1)
    }
    
    // MARK: Remove All Objects
    
    func testRemoveAllObjects_removesAllObjects() {
        var subject = OrderedSet<String>(sequence: ["One", "Two", "Three"])
        subject.removeAllObjects()
        XCTAssertEqual(subject.count, 0)
    }
    
    // MARK: Intersects Sequence
    
    func testIntersectsSequence_withoutIntersection_isFalse() {
        let subject = OrderedSet<String>(sequence: ["One", "Two", "Three"])
        XCTAssertFalse(subject.intersects(["Four"]))
    }
    
    func testIntersectsSequence_withIntersection_isTrue() {
        let subject = OrderedSet<String>(sequence: ["One", "Two", "Three"])
        XCTAssertTrue(subject.intersects(["Two"]))
    }
    
    // MARK: Is Subset Of Sequence
    
    func testIsSubsetOfSequence_whenIsSubset_isTrue() {
        let subject = OrderedSet<String>(sequence: ["One", "Two", "Three"])
        XCTAssertTrue(subject.isSubset(of: ["Three", "Two", "One"]))
    }
    
    func testIsSubsetOfSequence_whenIsSubset_andContainsDuplicates_isTrue() {
        let subject = OrderedSet<String>(sequence: ["One", "Two", "Three"])
        XCTAssertTrue(subject.isSubset(of: ["Three", "Two", "One", "Three"]))
    }
    
    func testIsSubsetOfSequence_whenIsNotSubset_isFalse() {
        let subject = OrderedSet<String>(sequence: ["One", "Two"])
        XCTAssertTrue(subject.isSubset(of: ["Three", "Two", "One"]))
    }
    
    // MARK: Concatenation
    
    func testConcatingOrderedSets_returnsJoinedSet() {
        let first: OrderedSet<String> = ["One"]
        let second: OrderedSet<String> = ["One", "Two"]
        let result = first + second
        XCTAssertEqual(result.count, 2)
        XCTAssert(result[0] == "One")
        XCTAssert(result[1] == "Two")
    }
    
    func testConcatAppendOrderedSets_returnsJoinedOrderedSet() {
        var subject: OrderedSet<String> = ["One"]
        let second: OrderedSet<String> = ["One", "Two"]
        subject += second
        XCTAssertEqual(subject.count, 2)
        XCTAssert(subject[0] == "One")
        XCTAssert(subject[1] == "Two")
    }
    
    // MARK: Decatenate
    
    func testDecatenate_removesMatchedObjects() {
        let subject: OrderedSet<String> = ["One", "Two", "Three"]
        let second: OrderedSet<String> = ["One", "Three"]
        let result = subject - second
        XCTAssertEqual(result.count, 1)
        XCTAssert(result[0] == "Two")
    }
    
    func testDecatenateEquals_removesMatchedObjects() {
        var subject: OrderedSet<String> = ["One", "Two", "Three"]
        let second: OrderedSet<String> = ["One", "Three"]
        subject -= second
        XCTAssertEqual(subject.count, 1)
        XCTAssert(subject[0] == "Two")
    }
    
    // MARK: Map
    
    func testMap_mapsEachObject() {
        let subject: OrderedSet<String> = ["One", "Two", "Three"]
        let result = subject.map { $0.hashValue }
        let expected = ["One".hashValue, "Two".hashValue, "Three".hashValue]
        XCTAssertTrue(result == expected)
    }
    
    // MARK: Equality
    
    func testEquals_isTrue_whenEqual() {
        let first: OrderedSet<String> = ["One", "Two", "Three"]
        let second: OrderedSet<String> = ["One", "Two", "Three"]
        XCTAssertEqual(first, second)
    }
    
    func testEquals_isFalse_whenNotEqual() {
        let first: OrderedSet<String> = ["One", "Two", "Three"]
        let second: OrderedSet<String> = ["One", "Two", "Four"]
        XCTAssertNotEqual(first, second)
    }
    
    func testEquals_isFalse_whenFirstArrayIsLargerThanSecond() {
        let first: OrderedSet<String> = ["One", "Two", "Three", "Four"]
        let second: OrderedSet<String> = ["One", "Two", "Three"]
        XCTAssertNotEqual(first, second)
    }
    
    func testEquals_isFalse_whenSecondArrayIsLargerThanFirst() {
        let first: OrderedSet<String> = ["One", "Two", "Three"]
        let second: OrderedSet<String> = ["One", "Two", "Three", "Four"]
        XCTAssertNotEqual(first, second)
    }
    
    func testEquals_isFalse_whenSecondArrayIsDifferentOrderThanFirst() {
        let first: OrderedSet<String> = ["One", "Two", "Three"]
        let second: OrderedSet<String> = ["Three", "Two", "One"]
        XCTAssertNotEqual(first, second)
    }
    
    // MARK: First
    
    func testFirst_whenEmpty_isNil() {
        let subject = OrderedSet<String>()
        XCTAssert(subject.first == nil)
    }
    
    func testFirst_whenNotEmpty_isFirstElement() {
        let subject: OrderedSet<String> = ["One", "Two", "Three"]
        XCTAssert(subject.first == "One")
    }
    
    // MARK: Last
    
    func testLast_whenEmpty_isNil() {
        let subject = OrderedSet<String>()
        XCTAssert(subject.last == nil)
    }
    
    func testLast_whenNotEmpty_isFirstElement() {
        let subject: OrderedSet<String> = ["One", "Two", "Three"]
        XCTAssert(subject.last == "Three")
    }

    // MARK: - Swap Object
    
    func testSwapObject_whenBothObjectsExist_swapsBothObjects() {
        var subject: OrderedSet<String> = ["One", "Two", "Three"]
        subject.swapObject("One", with: "Three")
        let expected: OrderedSet<String> = ["Three", "Two", "One"]
        XCTAssertEqual(subject, expected)
    }
    
    func testSwapObject_whenOneObjectsExist_doesntChangeSet() {
        var subject: OrderedSet<String> = ["One", "Two", "Three"]
        subject.swapObject("One", with: "Four")
        let expected: OrderedSet<String> = ["One", "Two", "Three"]
        XCTAssertEqual(subject, expected)
    }
    
    // MARK: Move Object to Index
    
    func testMoveObjectToIndex_whenObjectExists_whenMovingAmongEntireSet_movesObjectUp_andShiftsOthersDown() {
        var subject: OrderedSet<String> = ["One", "Two", "Three"]
        subject.moveObject("One", toIndex: 2)
        let expected: OrderedSet<String> = ["Two", "Three", "One"]
        XCTAssertEqual(subject, expected)
    }
    
    func testMoveObjectToIndex_whenObjectExists_whenMovingAmongEntireSet_movesObjectDown_andShiftsOthersUp() {
        var subject: OrderedSet<String> = ["One", "Two", "Three"]
        subject.moveObject("Three", toIndex: 0)
        let expected: OrderedSet<String> = ["Three", "One", "Two"]
        XCTAssertEqual(subject, expected)
    }
    
    func testMoveObjectToIndex_whenObjectExists_whenMovingAmongSubsetOfSet_movesObjectUp_andShiftsTraversedObjectsDown() {
        var subject: OrderedSet<String> = ["One", "Two", "Three", "Four", "Five"]
        subject.moveObject("Four", toIndex: 1)
        let expected: OrderedSet<String> = ["One", "Four", "Two", "Three", "Five"]
        XCTAssertEqual(subject, expected)
    }
    
    func testMoveObjectToIndex_whenObjectExists_whenMovingAmongSubsetOfSet_movesObjectDown_andShiftsTraversedObjectsUp() {
        var subject: OrderedSet<String> = ["One", "Two", "Three", "Four", "Five"]
        subject.moveObject("Two", toIndex: 3)
        let expected: OrderedSet<String> = ["One", "Three", "Four", "Two", "Five"]
        XCTAssertEqual(subject, expected)
    }
    
    func testMoveObjectToIndex_whenObjectDoesntExist_isNoop() {
        var subject: OrderedSet<String> = ["One", "Two", "Three"]
        subject.moveObject("Four", toIndex: 0)
        let expected: OrderedSet<String> = ["One", "Two", "Three"]
        XCTAssertEqual(subject, expected)
    }
    
    func testMoveObjectToIndex_whenObjectIsSameIndex_isNoop() {
        var subject: OrderedSet<String> = ["One", "Two", "Three"]
        subject.moveObject("One", toIndex: 0)
        let expected: OrderedSet<String> = ["One", "Two", "Three"]
        XCTAssertEqual(subject, expected)
    }
    
    func testMoveObject_withFullMove_mapsCorrectly() {
        var subject: OrderedSet<String> = ["One", "Two", "Three", "Four", "Five"]
        subject.moveObject("One", toIndex: 4)
        XCTAssertEqual(subject.map { $0 }, ["Two", "Three", "Four", "Five", "One"])
    }
    
    func testMoveObject_withInnerMove_mapsCorrectly() {
        var subject: OrderedSet<String> = ["p0", "p1", "c1", "p2", "p3", "c2"]
        subject.moveObject("p2", toIndex: 1)
        XCTAssertEqual(subject.map { $0 }, ["p0", "p2", "p1", "c1", "p3", "c2"])
    }
    
    // MARK: Insert Object at Index
    
    func testMoveObjectAtIndex_whenObjectExists_whenMovingAmongEntireSet_movesObjectUp_andShiftsOthersDown() {
        var subject: OrderedSet<String> = ["One", "Two", "Three"]
        subject.moveObject(at: 0, to: 2)
        let expected: OrderedSet<String> = ["Two", "Three", "One"]
        XCTAssertEqual(subject, expected)
    }
    
    func testMoveObjectAtIndex_whenObjectExists_whenMovingAmongEntireSet_movesObjectDown_andShiftsOthersUp() {
        var subject: OrderedSet<String> = ["One", "Two", "Three"]
        subject.moveObject(at: 2, to: 0)
        let expected: OrderedSet<String> = ["Three", "One", "Two"]
        XCTAssertEqual(subject, expected)
    }
    
    func testMoveObjectAtIndex_whenObjectExists_whenMovingAmongSubsetOfSet_movesObjectUp_andShiftsTraversedObjectsDown() {
        var subject: OrderedSet<String> = ["One", "Two", "Three", "Four", "Five"]
        subject.moveObject(at: 3, to: 1)
        let expected: OrderedSet<String> = ["One", "Four", "Two", "Three", "Five"]
        XCTAssertEqual(subject, expected)
    }
    
    func testMoveObjectAtIndex_whenObjectExists_whenMovingAmongSubsetOfSet_movesObjectDown_andShiftsTraversedObjectsUp() {
        var subject: OrderedSet<String> = ["One", "Two", "Three", "Four", "Five"]
        subject.moveObject(at: 1, to: 3)
        let expected: OrderedSet<String> = ["One", "Three", "Four", "Two", "Five"]
        XCTAssertEqual(subject, expected)
    }
    
    func testMoveObjectAtIndex_whenSameIndexes_isNoop() {
        var subject: OrderedSet<String> = ["One", "Two", "Three"]
        subject.moveObject(at: 0, to: 0)
        let expected: OrderedSet<String> = ["One", "Two", "Three"]
        XCTAssertEqual(subject, expected)
    }
    
    func testInsertObjectAtIndex_whenObjectDoesntExist_insertsObjectAtCorrectSpot() {
        var subject: OrderedSet<String> = ["One", "Two", "Three"]
        subject.insert("Zero", at: 0)
        let expected: OrderedSet<String> = ["Zero", "One", "Two", "Three"]
        XCTAssertEqual(subject, expected)
    }
    
    func testInsertObjectAtIndex_whenObjectDoesExist_isNoop() {
        var subject: OrderedSet<String> = ["One", "Two", "Three"]
        subject.insert("Two", at: 0)
        let expected: OrderedSet<String> = ["One", "Two", "Three"]
        XCTAssertEqual(subject, expected)
    }
    
    func testInsertObjectAtIndex_canInsertObjectAtTail() {
        var subject: OrderedSet<String> = ["One", "Two", "Three"]
        subject.insert("Four", at: 3)
        let expected: OrderedSet<String> = ["One", "Two", "Three", "Four"]
        XCTAssertEqual(subject, expected)
    }
    
    // MARK: Insert Objects at Index
    
    func testInsertObjectsAtIndex_whenObjectsDontExist_insertsObjectsAtCorrectSpot() {
        var subject: OrderedSet<String> = ["One", "Two", "Three"]
        subject.insert(["Foo", "Bar"], at: 1)
        let expected: OrderedSet<String> = ["One", "Foo", "Bar", "Two", "Three"]
        XCTAssertEqual(subject, expected)
    }
    
    func testInsertObjectsAtIndex_whenSomeObjectsExist_insertsOnlyNonExistingObjectsAtCorrectSpot() {
        var subject: OrderedSet<String> = ["One", "Two", "Three"]
        subject.insert(["Foo", "Three"], at: 1)
        let expected: OrderedSet<String> = ["One", "Foo", "Two", "Three"]
        XCTAssertEqual(subject, expected)
    }
    
    func testInsertObjectsAtIndex_whenRepeatedObjectsAreInserted_insertsOnlyOne() {
        var subject: OrderedSet<String> = ["One", "Two", "Three"]
        subject.insert(["Foo", "Foo"], at: 1)
        let expected: OrderedSet<String> = ["One", "Foo", "Two", "Three"]
        XCTAssertEqual(subject, expected)
    }
    
    func testInsertObjectsAtIndex_canInsertObjectAtTail() {
        var subject: OrderedSet<String> = ["One", "Two", "Three"]
        subject.insert(["Four", "Five"], at: 3)
        let expected: OrderedSet<String> = ["One", "Two", "Three", "Four", "Five"]
        XCTAssertEqual(subject, expected)
    }
    
    // MARK: Append Objects
    
    func testAppendObjects_whenObjectsDontExist_appendsAllObjects() {
        var subject: OrderedSet<String> = ["One", "Two", "Three"]
        subject.append(contentsOf: ["Foo", "Bar"])
        let expected: OrderedSet<String> = ["One", "Two", "Three", "Foo", "Bar"]
        XCTAssertEqual(subject, expected)
    }
    
    func testAppendObjects_whenSomeObjectsExist_appendsOnlyNonExistingObjects() {
        var subject: OrderedSet<String> = ["One", "Two", "Three"]
        subject.append(contentsOf: ["Foo", "Two"])
        let expected: OrderedSet<String> = ["One", "Two", "Three", "Foo"]
        XCTAssertEqual(subject, expected)
    }
    
    func testAppendObjects_whenRepeatedObjectsAreAppended_appendsOnlyOne() {
        var subject: OrderedSet<String> = ["One", "Two", "Three"]
        subject.append(contentsOf: ["Foo", "Foo"])
        let expected: OrderedSet<String> = ["One", "Two", "Three", "Foo"]
        XCTAssertEqual(subject, expected)
    }
    
    // MARK: Description
    
    func testDescription_printsDescription() {
        let subject: OrderedSet<String> = ["One", "Two", "Three"]
        XCTAssertEqual(subject.description, "OrderedSet (3 object(s)): [One, Two, Three]")
    }
    
}
