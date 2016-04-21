//
//  QueryTestCase.swift
//  LeanCloud
//
//  Created by Tang Tianyong on 4/20/16.
//  Copyright © 2016 LeanCloud. All rights reserved.
//

import XCTest
@testable import LeanCloud

let sharedObject: TestObject = {
    let object = TestObject()

    object.numberField  = 42
    object.booleanField = true
    object.stringField  = "foo"
    object.arrayField   = [LCNumber(42), LCString("bar"), sharedArrayElement]
    object.dateField    = LCDate(NSDate(timeIntervalSince1970: 1024))
    object.geoPointField = LCGeoPoint(latitude: 45, longitude: -45)

    XCTAssertTrue(object.save().isSuccess)

    return object
}()

let sharedArrayElement: TestObject = {
    let object = TestObject()
    XCTAssertTrue(object.save().isSuccess)
    return object
}()

class QueryTestCase: BaseTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testIncluded() {
        let object = sharedObject
        let child  = TestObject()

        object.objectField = child
        child.stringField = "bar"

        XCTAssertTrue(object.save().isSuccess)

        let query = Query(className: TestObject.className())
        query.whereKey("objectId", .EqualTo(value: object.objectId!))
        query.whereKey("objectField", .Included)

        let (response, objects) = query.find()
        XCTAssertTrue(response.isSuccess && !objects.isEmpty)

        if let child = (objects.first as? TestObject)?.objectField as? TestObject {
            XCTAssertEqual(child.stringField, "bar")
        } else {
            XCTFail()
        }
    }

    func testSelected() {
        let object = sharedObject
        let query  = Query(className: TestObject.className())

        query.whereKey("objectId", .EqualTo(value: object.objectId!))
        query.whereKey("stringField", .Selected)
        query.whereKey("booleanField", .Selected)

        let (response, objects) = query.find()
        XCTAssertTrue(response.isSuccess && !objects.isEmpty)

        let shadow = objects.first as! TestObject

        XCTAssertEqual(shadow.stringField, "foo")
        XCTAssertEqual(shadow.booleanField, true)
        XCTAssertNil(shadow.numberField)
    }

    func testExisted() {
        let object = sharedObject
        let query  = Query(className: TestObject.className())

        query.whereKey("objectId", .EqualTo(value: object.objectId!))
        query.whereKey("stringField", .Existed)

        let (response, objects) = query.find()
        XCTAssertTrue(response.isSuccess && !objects.isEmpty)
    }

    func testNotExisted() {
        let query = Query(className: TestObject.className())
        query.whereKey("objectId", .NotExisted)

        let (response, objects) = query.find()
        XCTAssertTrue(response.isSuccess && objects.isEmpty)
    }

    func testEqualTo() {
        let object = sharedObject
        let query  = Query(className: TestObject.className())

        query.whereKey("objectId", .EqualTo(value: object.objectId!))
        query.whereKey("dateField", .EqualTo(value: LCDate(NSDate(timeIntervalSince1970: 1024))))

        /* Tip: You can use EqualTo to compare an value against elements in an array field.
           If the given value is equal to any element in the array referenced by key, the comparation will be successful. */
        query.whereKey("arrayField", .EqualTo(value: sharedArrayElement))

        let (response, objects) = query.find()
        XCTAssertTrue(response.isSuccess && !objects.isEmpty)
    }

    func testNotEqualTo() {
        let object = sharedObject
        let query  = Query(className: TestObject.className())

        query.whereKey("objectId", .EqualTo(value: object.objectId!))
        query.whereKey("numberField", .NotEqualTo(value: LCNumber(42)))

        let (response, objects) = query.find()
        XCTAssertTrue(response.isSuccess && objects.isEmpty)
    }

    func testLessThan() {
        let object = sharedObject
        let query  = Query(className: TestObject.className())

        query.whereKey("objectId", .EqualTo(value: object.objectId!))
        query.whereKey("numberField", .LessThan(value: LCNumber(42)))

        let (response1, objects1) = query.find()
        XCTAssertTrue(response1.isSuccess && objects1.isEmpty)

        query.whereKey("numberField", .LessThan(value: LCNumber(43)))
        query.whereKey("dateField", .LessThan(value: LCDate(NSDate(timeIntervalSince1970: 1025))))

        let (response2, objects2) = query.find()
        XCTAssertTrue(response2.isSuccess && !objects2.isEmpty)
    }

    func testLessThanOrEqualTo() {
        let object = sharedObject
        let query  = Query(className: TestObject.className())

        query.whereKey("objectId", .EqualTo(value: object.objectId!))
        query.whereKey("numberField", .LessThanOrEqualTo(value: LCNumber(42)))

        let (response, objects) = query.find()
        XCTAssertTrue(response.isSuccess && !objects.isEmpty)
    }

    func testGreaterThan() {
        let object = sharedObject
        let query  = Query(className: TestObject.className())

        query.whereKey("objectId", .EqualTo(value: object.objectId!))
        query.whereKey("numberField", .GreaterThan(value: LCNumber(41.9)))

        let (response, objects) = query.find()
        XCTAssertTrue(response.isSuccess && !objects.isEmpty)
    }

    func testGreaterThanOrEqualTo() {
        let object = sharedObject
        let query  = Query(className: TestObject.className())

        query.whereKey("objectId", .EqualTo(value: object.objectId!))
        query.whereKey("dateField", .GreaterThanOrEqualTo(value: LCDate(NSDate(timeIntervalSince1970: 1023.9))))

        let (response, objects) = query.find()
        XCTAssertTrue(response.isSuccess && !objects.isEmpty)
    }

    func testContainedIn() {
        let object = sharedObject
        let query  = Query(className: TestObject.className())

        query.whereKey("objectId", .EqualTo(value: object.objectId!))

        /* Tip: You can use ContainedIn to compare an array of values against a non-array field.
           If any value in given array is equal to the value referenced by key, the comparation will be successful. */
        query.whereKey("dateField", .ContainedIn(array: [LCDate(NSDate(timeIntervalSince1970: 1024))]))

        /* Tip: Also, you can apply the constraint to array field. */
        query.whereKey("arrayField", .ContainedIn(array: [LCNumber(42), LCString("bar")]))

        let (response, objects) = query.find()
        XCTAssertTrue(response.isSuccess && !objects.isEmpty)
    }

    func testNotContainedIn() {
        let object = sharedObject
        let query  = Query(className: TestObject.className())

        query.whereKey("objectId", .EqualTo(value: object.objectId!))

        /* Tip: Like ContainedIn, you can apply NotContainedIn to non-array field. */
        query.whereKey("numberField", .NotContainedIn(array: [LCNumber(42)]))

        /* Tip: Also, you can apply the constraint to array field. */
        query.whereKey("arrayField", .NotContainedIn(array: [LCNumber(42), LCString("bar")]))

        let (response, objects) = query.find()
        XCTAssertTrue(response.isSuccess && objects.isEmpty)
    }

    func testContainedAllIn() {
        let object = sharedObject
        let query  = Query(className: TestObject.className())

        query.whereKey("objectId", .EqualTo(value: object.objectId!))

        /* Tip: Like ContainedIn, you can apply ContainedAllIn to non-array field. */
        query.whereKey("numberField", .ContainedAllIn(array: [LCNumber(42)]))

        /* Tip: Also, you can apply the constraint to array field. */
        query.whereKey("arrayField", .ContainedAllIn(array: [LCNumber(42), LCString("bar"), sharedArrayElement]))

        let (response, objects) = query.find()
        XCTAssertTrue(response.isSuccess && !objects.isEmpty)
    }

    func testEqualToSize() {
        let object = sharedObject
        let query  = Query(className: TestObject.className())

        query.whereKey("objectId", .EqualTo(value: object.objectId!))
        query.whereKey("arrayField", .EqualToSize(size: 3))

        let (response, objects) = query.find()
        XCTAssertTrue(response.isSuccess && !objects.isEmpty)
    }

    func testNearbyPoint() {
        let query = Query(className: TestObject.className())

        query.whereKey("geoPointField", .NearbyPoint(point: LCGeoPoint(latitude: 45, longitude: -45)))
        query.limit = 1

        let (response, objects) = query.find()
        XCTAssertTrue(response.isSuccess && !objects.isEmpty)
    }

    func testNearbyPointWithRange() {
        let query = Query(className: TestObject.className())

        /* Tip: At the equator, one degree of longitude and latitude is approximately equal to about 111 kilometers, or 70 miles. */

        let from = LCGeoPoint.Distance(value: 0, unit: .Kilometer)
        let to   = LCGeoPoint.Distance(value: 150, unit: .Kilometer)

        query.whereKey("geoPointField", .NearbyPointWithRange(point: LCGeoPoint(latitude: 44, longitude: -45), from: from, to: to))
        query.limit = 1

        let (response, objects) = query.find()
        XCTAssertTrue(response.isSuccess && !objects.isEmpty)
    }

    func testNearbyPointWithRectangle() {
        let query = Query(className: TestObject.className())

        let southwest = LCGeoPoint(latitude: 44, longitude: -46)
        let northeast = LCGeoPoint(latitude: 46, longitude: -44)

        query.whereKey("geoPointField", .NearbyPointWithRectangle(southwest: southwest, northeast: northeast))
        query.limit = 1

        let (response, objects) = query.find()
        XCTAssertTrue(response.isSuccess && !objects.isEmpty)
    }

}
