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
        let subject = OrderedSet(sorted: ["One"])
        XCTAssertFalse(subject.isEmpty)
    }
    
    // MARK: Subscript
    
    func testObjectSubscript_returnsCorrectObject() {
        let subject = OrderedSet<String>()
        subject.insert("Test")
        XCTAssert(subject[0] == "Test")
    }
    
    func testSubscriptInsertion_replacesObject() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three"])
        subject[1] = "wat"
        XCTAssertEqual(subject.count, 3)
        XCTAssert(subject[0] == "One")
        XCTAssert(subject[1] == "wat")
        XCTAssert(subject[2] == "Three")
    }
    
    func testSubscriptSetting_iteratesCorrectly() {
        let subject = OrderedSet(sorted: [0, 1, 2])
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
        let subject = OrderedSet<String>()
        subject.insert("Test")
        XCTAssertTrue(subject.contains("Test"))
    }

    func testContains_whenObjectIsNotContained_isFalse() {
        let subject = OrderedSet<String>()
        XCTAssertFalse(subject.contains("Test"))
    }
    
    // MARK: Enumeration
    
    func testEnumeration_enumeratesAllObjectsInOrder() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three"])
        var enumeratedObjects = [String]()
        for object in subject {
            enumeratedObjects.append(object)
        }
        
        let expected = ["One", "Two", "Three"]
        
        XCTAssertEqual(enumeratedObjects, expected)
    }

    // MARK: Init With Sequence
    
    func testInitWithSequence_withDuplicates_onlyCountsThemOnce() {
        let subject = OrderedSet(sorted: ["One", "Two", "Two", "Four"])
        XCTAssertEqual(subject.count, 3)
    }
    
    func testInitWithSequence_withDuplicates_doesntChangeIndexAfterFirst() {
        let subject = OrderedSet(sorted: ["One", "Two", "Two", "Four"])
        XCTAssert(subject[0] == "One")
        XCTAssert(subject[1] == "Two")
        XCTAssert(subject[2] == "Four")
    }

    // MARK: Init With Array Literal
    
    func testInitializingWithArrayLiteral_includesItemsInOrder() {
        let subject = OrderedSet(sorted: ["One", "Two"])
        var enumeratedObjects = [String]()
        for object in subject {
            enumeratedObjects.append(object)
        }
        
        let expected = ["One", "Two"]
        
        XCTAssertEqual(enumeratedObjects, expected)
    }
    
    // MARK: Index Of Object
    
    func testIndexOfObject_whenObjectExists_isCorrectIndex() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three"])
        XCTAssert(subject.index(of: "Three") == 2)
    }
    
    func testIndexOfObject_whenObjectDoesntExist_isNil() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three"])
        XCTAssertNil(subject.index(of: "Four"))
    }
    
    // MARK: Remove
    
    func testRemove_whenObjectExists_reducesCount() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three"])
        subject.remove("Two")
        XCTAssertEqual(subject.count, 2)
    }
    
    func testRemove_whenObjectDoesntExist_doesntChangeCount() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three"])
        subject.remove("Twoz")
        XCTAssertEqual(subject.count, 3)
    }
    
    func testRemove_whenObjectIsNotLast_updatesOrdering() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three", "Four"])
        subject.remove("Two")
        XCTAssert(subject[0] == "One")
        XCTAssert(subject[1] == "Three")
        XCTAssert(subject[2] == "Four")
    }
    
    // MARK: Remove Objects
    
    func testRemoveObjects_removesPassedInObjects() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three", "Four"])
        subject.remove(["Two", "Four"])
        let expected = OrderedSet(sorted: ["One", "Three"])
        XCTAssertEqual(subject, expected)
    }
    
    // MARK: Remove Object At Index
    
    func testRemoveObjectAtIndex_removesTheObjectAtIndex() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three", "Four"])
        subject.removeObject(at: 1)
        let expected = OrderedSet(sorted: ["One", "Three", "Four"])
        XCTAssertEqual(subject, expected)
    }
    
    // MARK: Remove All Objects
    
    func testRemoveAllObjects_removesAllObjects() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three"])
        subject.removeAllObjects()
        XCTAssertEqual(subject.count, 0)
    }
    
    // MARK: Intersects Sequence
    
    func testIntersectsSequence_withoutIntersection_isFalse() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three"])
        XCTAssertFalse(subject.intersects(["Four"]))
    }
    
    func testIntersectsSequence_withIntersection_isTrue() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three"])
        XCTAssertTrue(subject.intersects(["Two"]))
    }
    
    // MARK: Is Subset Of Sequence
    
    func testIsSubsetOfSequence_whenIsSubset_isTrue() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three"])
        XCTAssertTrue(subject.isSubset(of: ["Three", "Two", "One"]))
    }
    
    func testIsSubsetOfSequence_whenIsSubset_andContainsDuplicates_isTrue() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three"])
        XCTAssertTrue(subject.isSubset(of: ["Three", "Two", "One", "Three"]))
    }
    
    func testIsSubsetOfSequence_whenIsNotSubset_isFalse() {
        let subject = OrderedSet(sorted: ["One", "Two"])
        XCTAssertTrue(subject.isSubset(of: ["Three", "Two", "One"]))
    }
    
    // MARK: Concatenation
    
    func testConcatingOrderedSets_returnsJoinedSet() {
        let first = OrderedSet(sorted: ["One"])
        let second = OrderedSet(sorted: ["One", "Two"])
        let result = first + second
        XCTAssertEqual(result.count, 2)
        XCTAssert(result[0] == "One")
        XCTAssert(result[1] == "Two")
    }
    
    func testConcatAppendOrderedSets_returnsJoinedOrderedSet() {
        var first = OrderedSet(sorted: ["One"])
        let second = OrderedSet(sorted: ["One", "Two"])
        first += second
        XCTAssertEqual(first.count, 2)
        XCTAssert(first[0] == "One")
        XCTAssert(first[1] == "Two")
    }
    
    // MARK: Decatenate
    
    func testDecatenate_removesMatchedObjects() {
        let first = OrderedSet(sorted: ["One", "Two", "Three"])
        let second = OrderedSet(sorted: ["One", "Three"])
        let result = first - second
        XCTAssertEqual(result.count, 1)
        XCTAssert(result[0] == "Two")
    }
    
    func testDecatenateEquals_removesMatchedObjects() {
        var first = OrderedSet(sorted: ["One", "Two", "Three"])
        let second = OrderedSet(sorted: ["One", "Three"])
        first -= second
        XCTAssertEqual(first.count, 1)
        XCTAssert(first[0] == "Two")
    }
    
    // MARK: Map
    
    func testMap_mapsEachObject() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three"])
        let result = subject.map { $0.hashValue }
        let expected = ["One".hashValue, "Two".hashValue, "Three".hashValue]
        XCTAssertTrue(result == expected)
    }
    
    // MARK: Equality
    
    func testEquals_isTrue_whenEqual() {
        let first = OrderedSet(sorted: ["One", "Two", "Three"])
        let second = OrderedSet(sorted: ["One", "Two", "Three"])
        XCTAssertEqual(first, second)
    }
    
    func testEquals_isFalse_whenNotEqual() {
        let first = OrderedSet(sorted: ["One", "Two", "Three"])
        let second = OrderedSet(sorted: ["One", "Two", "Four"])
        XCTAssertNotEqual(first, second)
    }
    
    func testEquals_isFalse_whenFirstArrayIsLargerThanSecond() {
        let first = OrderedSet(sorted: ["One", "Two", "Three", "Four"])
        let second = OrderedSet(sorted: ["One", "Two", "Three"])
        XCTAssertNotEqual(first, second)
    }
    
    func testEquals_isFalse_whenSecondArrayIsLargerThanFirst() {
        let first = OrderedSet(sorted: ["One", "Two", "Three"])
        let second = OrderedSet(sorted: ["One", "Two", "Three", "Four"])
        XCTAssertNotEqual(first, second)
    }
    
    func testEquals_isFalse_whenSecondArrayIsDifferentOrderThanFirst() {
        let first = OrderedSet(sorted: ["One", "Two", "Three"])
        let second = OrderedSet(sorted: ["Three", "Two", "One"])
        XCTAssertNotEqual(first, second)
    }
    
    // MARK: First
    
    func testFirst_whenEmpty_isNil() {
        let subject = OrderedSet<String>()
        XCTAssert(subject.first == nil)
    }
    
    func testFirst_whenNotEmpty_isFirstElement() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three"])
        XCTAssert(subject.first == "One")
    }
    
    // MARK: Last
    
    func testLast_whenEmpty_isNil() {
        let subject = OrderedSet<String>()
        XCTAssert(subject.last == nil)
    }
    
    func testLast_whenNotEmpty_isFirstElement() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three"])
        XCTAssert(subject.last == "Three")
    }

    // MARK: - Swap Object
    
    func testSwapObject_whenBothObjectsExist_swapsBothObjects() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three"])
        subject.swapObject("One", with: "Three")
        let expected = OrderedSet(sorted: ["Three", "Two", "One"])
        XCTAssertEqual(subject, expected)
    }
    
    func testSwapObject_whenOneObjectsExist_doesntChangeSet() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three"])
        subject.swapObject("One", with: "Four")
        let expected = OrderedSet(sorted: ["One", "Two", "Three"])
        XCTAssertEqual(subject, expected)
    }
    
    // MARK: Move Object to Index
    
    func testMoveObjectToIndex_whenObjectExists_whenMovingAmongEntireSet_movesObjectUp_andShiftsOthersDown() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three"])
        subject.moveObject("One", toIndex: 2)
        let expected = OrderedSet(sorted: ["Two", "Three", "One"])
        XCTAssertEqual(subject, expected)
    }
    
    func testMoveObjectToIndex_whenObjectExists_whenMovingAmongEntireSet_movesObjectDown_andShiftsOthersUp() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three"])
        subject.moveObject("Three", toIndex: 0)
        let expected = OrderedSet(sorted: ["Three", "One", "Two"])
        XCTAssertEqual(subject, expected)
    }
    
    func testMoveObjectToIndex_whenObjectExists_whenMovingAmongSubsetOfSet_movesObjectUp_andShiftsTraversedObjectsDown() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three", "Four", "Five"])
        subject.moveObject("Four", toIndex: 1)
        let expected = OrderedSet(sorted: ["One", "Four", "Two", "Three", "Five"])
        XCTAssertEqual(subject, expected)
    }
    
    func testMoveObjectToIndex_whenObjectExists_whenMovingAmongSubsetOfSet_movesObjectDown_andShiftsTraversedObjectsUp() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three", "Four", "Five"])
        subject.moveObject("Two", toIndex: 3)
        let expected = OrderedSet(sorted: ["One", "Three", "Four", "Two", "Five"])
        XCTAssertEqual(subject, expected)
    }
    
    func testMoveObjectToIndex_whenObjectDoesntExist_isNoop() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three"])
        subject.moveObject("Four", toIndex: 0)
        let expected = OrderedSet(sorted: ["One", "Two", "Three"])
        XCTAssertEqual(subject, expected)
    }
    
    func testMoveObjectToIndex_whenObjectIsSameIndex_isNoop() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three"])
        subject.moveObject("One", toIndex: 0)
        let expected = OrderedSet(sorted: ["One", "Two", "Three"])
        XCTAssertEqual(subject, expected)
    }
    
    func testMoveObject_withFullMove_mapsCorrectly() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three", "Four", "Five"])
        subject.moveObject("One", toIndex: 4)
        XCTAssertEqual(subject.map { $0 }, ["Two", "Three", "Four", "Five", "One"])
    }
    
    func testMoveObject_withInnerMove_mapsCorrectly() {
        let subject = OrderedSet(sorted: ["p0", "p1", "c1", "p2", "p3", "c2"])
        subject.moveObject("p2", toIndex: 1)
        XCTAssertEqual(subject.map { $0 }, ["p0", "p2", "p1", "c1", "p3", "c2"])
    }
    
    // MARK: Insert Object at Index
    
    func testMoveObjectAtIndex_whenObjectExists_whenMovingAmongEntireSet_movesObjectUp_andShiftsOthersDown() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three"])
        subject.moveObject(at: 0, to: 2)
        let expected = OrderedSet(sorted: ["Two", "Three", "One"])
        XCTAssertEqual(subject, expected)
    }
    
    func testMoveObjectAtIndex_whenObjectExists_whenMovingAmongEntireSet_movesObjectDown_andShiftsOthersUp() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three"])
        subject.moveObject(at: 2, to: 0)
        let expected = OrderedSet(sorted: ["Three", "One", "Two"])
        XCTAssertEqual(subject, expected)
    }
    
    func testMoveObjectAtIndex_whenObjectExists_whenMovingAmongSubsetOfSet_movesObjectUp_andShiftsTraversedObjectsDown() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three", "Four", "Five"])
        subject.moveObject(at: 3, to: 1)
        let expected = OrderedSet(sorted: ["One", "Four", "Two", "Three", "Five"])
        XCTAssertEqual(subject, expected)
    }
    
    func testMoveObjectAtIndex_whenObjectExists_whenMovingAmongSubsetOfSet_movesObjectDown_andShiftsTraversedObjectsUp() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three", "Four", "Five"])
        subject.moveObject(at: 1, to: 3)
        let expected = OrderedSet(sorted: ["One", "Three", "Four", "Two", "Five"])
        XCTAssertEqual(subject, expected)
    }
    
    func testMoveObjectAtIndex_whenSameIndexes_isNoop() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three"])
        subject.moveObject(at: 0, to: 0)
        let expected = OrderedSet(sorted: ["One", "Two", "Three"])
        XCTAssertEqual(subject, expected)
    }
    
    func testInsertObject_whenObjectDoesntExist_insertsObjectAtCorrectSpot() {
        let subject = OrderedSet(sorted: [1, 2, 3])
        subject.insert(0)
        let expected = OrderedSet(sorted: [0, 1, 2, 3])
        XCTAssertEqual(subject, expected)
    }
    
    func testInsertObject_whenObjectDoesExist_isNoop() {
        let subject = OrderedSet(sorted: [1, 2, 3])
        let expected = OrderedSet(sorted: [1, 2, 3])
        XCTAssertEqual(subject, expected)
    }
    
    func testInsertObjectOutcome_whenObjectDoesExist_isNoop() {
        let subject = OrderedSet(sorted: [1, 2, 3])
        let outcome = subject.insert(2)
        XCTAssertFalse(outcome.didInsert)
    }
    
    func testInsertObject_canInsertObjectAtTail() {
        let subject = OrderedSet(sorted: [1, 2, 3])
        subject.insert(4)
        let expected = OrderedSet(sorted: [1, 2, 3, 4])
        XCTAssertEqual(subject, expected)
    }
    
    func testInsertObjectOutcome_canInsertObjectAtTail() {
        let subject = OrderedSet(sorted: [1, 2, 3])
        let outcome = subject.insert(4)
        XCTAssertTrue(outcome.didInsert)
    }
    
    // MARK: Insert Objects at Index
    
    func testInsertObjectsAtIndex_whenObjectsDontExist_insertsObjectsAtCorrectSpot() {
        let subject = OrderedSet(sorted: [1, 2, 4, 6])
        subject.insert([3, 5])
        let expected = OrderedSet(sorted: [1, 2, 3, 4, 5, 6])
        XCTAssertEqual(subject, expected)
    }
    
    func testInsertObjectsAtIndex_whenSomeObjectsExist_insertsOnlyNonExistingObjectsAtCorrectSpot() {
        let subject = OrderedSet(sorted: [1, 2, 3])
        subject.insert([2, 4])
        let expected = OrderedSet(sorted: [1, 2, 3, 4])
        XCTAssertEqual(subject, expected)
    }
    
    func testInsertObjectsAtIndex_whenRepeatedObjectsAreInserted_insertsOnlyOne() {
        let subject = OrderedSet(sorted: [1, 2, 3])
        subject.insert([4, 4])
        let expected = OrderedSet(sorted: [1, 2, 3, 4])
        XCTAssertEqual(subject, expected)
    }
    
    func testInsertObjectsAtIndex_canInsertObjectAtTail() {
        let subject = OrderedSet(sorted: [1, 2, 3])
        subject.insert([4, 5])
        let expected = OrderedSet(sorted: [1, 2, 3, 4, 5])
        XCTAssertEqual(subject, expected)
    }
    
    // MARK: Description
    
    func testDescription_printsDescription() {
        let subject = OrderedSet(sorted: ["One", "Two", "Three"])
        XCTAssertEqual(subject.description, "OrderedSet (3 object(s)): [One, Two, Three]")
    }
    
    // MARK: Additional
    
    func testInitUnsortedSorts() {
        let subject = OrderedSet(unsorted: [3, 4, 2, 1], areInIncreasingOrder: <)
        let expected = OrderedSet(sorted: [1, 2, 3, 4])
        XCTAssertEqual(subject, expected)
    }
    
    func testConvenienceInitsUseLessThan() {
        let subject = OrderedSet(unsorted: ["a","c","b"])
        let expected = OrderedSet(sorted: ["a","b","c"])
        XCTAssertEqual(subject, expected)
    }
    
    func testInitSortedDoesntResort() {
        // Warning: this is not a valid way to create a OrderedSet
        let subject = OrderedSet(sorted: [3,2,1])
        let expected = OrderedSet(sorted: [3,2,1])
        XCTAssertEqual(subject, expected)
    }
    
    func testSortedArrayCanUseArbitraryComparisonPredicate() {
        struct Person: Hashable {
            var firstName: String
            var lastName: String
            var hashValue: Int {
                return firstName.hashValue ^ lastName.hashValue
            }
        }
        let a = Person(firstName: "A", lastName: "Smith")
        let b = Person(firstName: "B", lastName: "Jones")
        let c = Person(firstName: "C", lastName: "Lewis")
        
        let subject = OrderedSet<Person> { $0.firstName > $1.firstName }
        subject.insert([b, a, c])
        XCTAssertEqual(subject.map { $0.firstName }, ["C","B","A"])
    }
    
    
    func testInsertInEmptyArrayReturnsInsertionIndex() {
        let subject = OrderedSet<Int>()
        let outcome = subject.insert(10)
        XCTAssertEqual(outcome.index, 0)
    }
    
    func testInsertEqualElementReturnsCorrectInsertionIndex() {
        let subject = OrderedSet(unsorted: [3,1,0,2,1])
        let outcome = subject.insert(1)
        XCTAssert(outcome.index == 1 || outcome.index == 2 || outcome.index == 3)
    }
    
    func testInsertContentsOfPreservesSortOrder() {
        let subject = OrderedSet(unsorted: [10,9,8])
        let a = (7...11).reversed()
        subject.insert(Array(a))
        let expected = OrderedSet(unsorted: [7,8,8,9,9,10,10,11])
        XCTAssertEqual(subject, expected)
    }
    
    func testIndexOfReturnsNilForEmptyArray() {
        let subject = OrderedSet<Int>()
        let index = subject.index(of: 1)
        XCTAssertNil(index)
    }
    
    func testIndexOfCanDealWithSingleElementArray() {
        let subject = OrderedSet(unsorted: [5])
        let index = subject.index(of: 5)
        XCTAssertEqual(index, 0)
    }
    
    func testIndexOfFindsFirstIndexOfDuplicateElements1() {
        let subject = OrderedSet(unsorted: [1,2,3,3,3,3,3,3,3,3,4,5])
        let index = subject.index(of: 3)
        XCTAssertEqual(index, 2)
    }
    
    func testIndexOfFindsFirstIndexOfDuplicateElements2() {
        let subject = OrderedSet(unsorted: [1,4,4,4,4,4,4,4,4,3,2])
        let index = subject.index(of: 4)
        XCTAssertEqual(index, 3)
    }
    
    func testIndexOfFindsFirstIndexOfDuplicateElements3() {
        let subject = OrderedSet(unsorted: String(repeating: "A", count: 10))
        let index = subject.index(of: "A")
        XCTAssertEqual(index, 0)
    }
    
    func testIndexOfFindsFirstIndexOfDuplicateElements4() {
        let subject = OrderedSet<Character>(unsorted: Array(repeating: "a", count: 100_000))
        let index = subject.index(of: "a")
        XCTAssertEqual(index, 0)
    }
    
    func testIndexOfFindsFirstIndexOfDuplicateElements5() {
        let sourceArray = Array(repeating: 5, count: 100_000) + [1,2,6,7,8,9]
        let subject = OrderedSet(unsorted: sourceArray)
        let index = subject.index(of: 5)
        XCTAssertEqual(index, 2)
    }
    
    func testIndexOfExistsAndIsAnAliasForFirstIndexOf() {
        let subject = OrderedSet(unsorted: [1,2,3,3,3,3,3,3,3,3,4,5])
        let index = subject.index(of: 3)
        XCTAssertEqual(index, 2)
    }
    
    func testsContains() {
        let subject = OrderedSet(unsorted: "Lorem ipsum")
        XCTAssertTrue(subject.contains(" "))
        XCTAssertFalse(subject.contains("a"))
    }
    
    func testMin() {
        let subject = OrderedSet(unsorted: -10...10)
        XCTAssertEqual(subject.min(), -10)
    }
    
    func testMax() {
        let subject = OrderedSet(unsorted: -10...(-1))
        XCTAssertEqual(subject.max(), -1)
    }
    
    func testFilter() {
        let subject = OrderedSet(unsorted: ["a", "b", "c"])
        XCTAssertEqual(subject.filter { $0 != "a" }, ["b", "c"])
    }
    
    func testRemoveElementAtBeginningPreservesSortOrder() {
        let subject = OrderedSet(unsorted: 1...3)
        subject.remove(1)
        let expected = OrderedSet(sorted: 2...3)
        XCTAssertEqual(subject, expected)
    }
    
    func testRemoveElementInMiddlePreservesSortOrder() {
        let subject = OrderedSet(unsorted: 1...5)
        subject.remove(4)
        let expected = OrderedSet(sorted: [1,2,3,5])
        XCTAssertEqual(subject, expected)
    }
    
    func testRemoveElementAtEndPreservesSortOrder() {
        let subject = OrderedSet(unsorted: 1...3)
        subject.remove(3)
        let expected = OrderedSet(sorted: [1, 2])
        XCTAssertEqual(subject, expected)
    }
}
