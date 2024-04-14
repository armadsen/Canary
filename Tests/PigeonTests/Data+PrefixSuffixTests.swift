//
//  Data+PrefixSuffixTests.swift
//  
//
//  Created by Andrew R Madsen on 4/13/24.
//

import XCTest
@testable import Pigeon

final class Data_PrefixSuffixTests: XCTestCase {

    func testDataHasPrefix() {
        let data = "1234567890abcdef".data(using: .utf8)!
        let goodPrefix = "1234".data(using: .utf8)!
        let badPrefix = "6789".data(using: .utf8)!
        let longPrefix = "1234567890abcdef1234567890abcdef".data(using: .utf8)!

        XCTAssertFalse(data.hasPrefix(longPrefix))
        XCTAssertFalse(data.hasPrefix(badPrefix))
        XCTAssertTrue(data.hasPrefix(goodPrefix))
        XCTAssertTrue(data.hasPrefix(data))
    }

    func testDataHasSuffix() {
        let data = "1234567890abcdef".data(using: .utf8)!
        let goodSuffix = "cdef".data(using: .utf8)!
        let badSuffix = "6789".data(using: .utf8)!
        let longSuffix = "1234567890abcdef1234567890abcdef".data(using: .utf8)!

        XCTAssertFalse(data.hasSuffix(longSuffix))
        XCTAssertFalse(data.hasSuffix(badSuffix))
        XCTAssertTrue(data.hasSuffix(goodSuffix))
        XCTAssertTrue(data.hasSuffix(data))
    }

}
