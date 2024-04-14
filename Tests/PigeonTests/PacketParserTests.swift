//
//  PacketParserTests.swift
//  
//
//  Created by Andrew R Madsen on 4/13/24.
//

import XCTest
@testable import Pigeon

final class PacketParserTests: XCTestCase {

    func testEvaluatedPackets() {
        let parser = PacketParser(definition: .evaluated({ data in
            if !data.hasPrefix("!".data(using: .utf8)!) {
                return false
            }

            if !data.hasSuffix(";".data(using: .utf8)!) {
                return false
            }

            if data.count < 5 {
                return false
            }

            guard let string = String(data: data, encoding: .utf8) else {
                return false
            }

            if string.rangeOfCharacter(from: .decimalDigits) != nil {
                return false
            }

            return true
        }))

        var packets = parser.packetsByAppending(data: Data())
        XCTAssertTrue(packets.isEmpty)

        parser.append(data: "!inf".data(using: .utf8)!)
        packets = parser.popReceivedPackets()
        XCTAssertTrue(packets.isEmpty)
        XCTAssertEqual(parser.buffer, "!inf".data(using: .utf8)!)

        parser.append(data: "!info;".data(using: .utf8)!)
        packets = parser.popReceivedPackets()
        XCTAssertEqual(packets.count, 1)
        XCTAssertEqual(packets[0], "!info;".data(using: .utf8)!)
        XCTAssertTrue(parser.buffer.isEmpty)

        parser.append(data: "!hi;".data(using: .utf8)!)
        packets = parser.popReceivedPackets()
        XCTAssertEqual(packets.count, 0)

        parser.append(data: "there;".data(using: .utf8)!)
        packets = parser.popReceivedPackets()
        XCTAssertEqual(packets.count, 1)
        XCTAssertEqual(packets[0], "!hi;there;".data(using: .utf8)!)
        XCTAssertTrue(parser.buffer.isEmpty)

        parser.append(data: "asdf!info;hello".data(using: .utf8)!)
        packets = parser.popReceivedPackets()
        XCTAssertEqual(packets.count, 1)
        XCTAssertEqual(packets[0], "!info;".data(using: .utf8)!)
        XCTAssertEqual(parser.buffer, "hello".data(using: .utf8)!)

        parser.append(data: "!hel;lo;!world;abc!tes".data(using: .utf8)!)
        packets = parser.popReceivedPackets()
        XCTAssertEqual(packets.count, 2)
        XCTAssertEqual(packets[0], "!hel;".data(using: .utf8)!)
        XCTAssertEqual(packets[1], "!world;".data(using: .utf8)!)
        XCTAssertEqual(parser.buffer, "abc!tes".data(using: .utf8)!)
    }

    func testSimpleRangeDelimitedPackets() {
        let parser = PacketParser(definition: .rangeDelimited("!".data(using: .utf8)!, ";".data(using: .utf8)!))
        var packets = parser.packetsByAppending(data: Data())
        XCTAssertTrue(packets.isEmpty)

        parser.append(data: "!inf".data(using: .utf8)!)
        packets = parser.popReceivedPackets()
        XCTAssertTrue(packets.isEmpty)
        XCTAssertEqual(parser.buffer, "!inf".data(using: .utf8)!)

        parser.append(data: "o;".data(using: .utf8)!)
        packets = parser.popReceivedPackets()
        XCTAssertEqual(packets.count, 1)
        XCTAssertEqual(packets[0], "!info;".data(using: .utf8)!)
        XCTAssertTrue(parser.buffer.isEmpty)

        parser.append(data: "!hello;!world".data(using: .utf8)!)
        packets = parser.popReceivedPackets()
        XCTAssertEqual(packets.count, 1)
        XCTAssertEqual(packets[0], "!hello;".data(using: .utf8)!)
        XCTAssertEqual(parser.buffer, "!world".data(using: .utf8)!)
    }

    func testMoreComplexRangeDelimitedPackets() {
        let parser = PacketParser(definition: .rangeDelimited("!".data(using: .utf8)!, ";".data(using: .utf8)!))
        var packets = parser.packetsByAppending(data: Data())
        XCTAssertTrue(packets.isEmpty)

        parser.append(data: "!inf".data(using: .utf8)!)
        packets = parser.popReceivedPackets()
        XCTAssertTrue(packets.isEmpty)
        XCTAssertEqual(parser.buffer, "!inf".data(using: .utf8)!)

        parser.append(data: "!info;".data(using: .utf8)!)
        packets = parser.popReceivedPackets()
        XCTAssertEqual(packets.count, 1)
        XCTAssertEqual(packets[0], "!info;".data(using: .utf8)!)
        XCTAssertTrue(parser.buffer.isEmpty)

        parser.append(data: "!hel;lo;!world;abc!tes".data(using: .utf8)!)
        packets = parser.popReceivedPackets()
        XCTAssertEqual(packets.count, 2)
        XCTAssertEqual(packets[0], "!hel;".data(using: .utf8)!)
        XCTAssertEqual(packets[1], "!world;".data(using: .utf8)!)
        XCTAssertEqual(parser.buffer, "!tes".data(using: .utf8)!)

        parser.append(data: "t;".data(using: .utf8)!)
        packets = parser.popReceivedPackets()
        XCTAssertEqual(packets.count, 1)
        XCTAssertEqual(packets[0], "!test;".data(using: .utf8)!)
        XCTAssertTrue(parser.buffer.isEmpty)
    }

    func testEndDelimitedPackets() {
        let parser = PacketParser(definition: .endDelimited(".;".data(using: .utf8)!))
        var packets = parser.packetsByAppending(data: Data())
        XCTAssertTrue(packets.isEmpty)

        parser.append(data: "123".data(using: .utf8)!)
        packets = parser.popReceivedPackets()
        XCTAssertTrue(packets.isEmpty)
        XCTAssertEqual(parser.buffer, "123".data(using: .utf8)!)

        parser.append(data: "45.;".data(using: .utf8)!)
        packets = parser.popReceivedPackets()
        XCTAssertEqual(packets.count, 1)
        XCTAssertEqual(packets[0], "12345.;".data(using: .utf8)!)
        XCTAssertTrue(parser.buffer.isEmpty)

        parser.append(data: "1234.;5678.;90".data(using: .utf8)!)
        packets = parser.popReceivedPackets()
        XCTAssertEqual(packets.count, 2)
        XCTAssertEqual(packets[0], "1234.;".data(using: .utf8)!)
        XCTAssertEqual(packets[1], "5678.;".data(using: .utf8)!)
        XCTAssertEqual(parser.buffer, "90".data(using: .utf8)!)

        parser.append(data: "a.;bcde.f.;qq".data(using: .utf8)!)
        packets = parser.popReceivedPackets()
        XCTAssertEqual(packets.count, 2)
        XCTAssertEqual(packets[0], "90a.;".data(using: .utf8)!)
        XCTAssertEqual(packets[1], "bcde.f.;".data(using: .utf8)!)
        XCTAssertEqual(parser.buffer, "qq".data(using: .utf8)!)
    }

    func testFixedLengthPackets() {
        let parser = PacketParser(definition: .fixedLength(5))
        var packets = parser.packetsByAppending(data: Data())
        XCTAssertTrue(packets.isEmpty)
        
        parser.append(data: "123".data(using: .utf8)!)
        packets = parser.popReceivedPackets()
        XCTAssertTrue(packets.isEmpty)
        XCTAssertEqual(parser.buffer, "123".data(using: .utf8)!)
        
        parser.append(data: "45".data(using: .utf8)!)
        packets = parser.popReceivedPackets()
        XCTAssertEqual(packets.count, 1)
        XCTAssertEqual(packets[0], "12345".data(using: .utf8)!)
        XCTAssertTrue(parser.buffer.isEmpty)

        parser.append(data: "67890abc".data(using: .utf8)!)
        packets = parser.popReceivedPackets()
        XCTAssertEqual(packets.count, 1)
        XCTAssertEqual(packets[0], "67890".data(using: .utf8)!)
        XCTAssertEqual(parser.buffer, "abc".data(using: .utf8)!)

        parser.append(data: "defghij".data(using: .utf8)!)
        packets = parser.popReceivedPackets()
        XCTAssertEqual(packets.count, 2)
        XCTAssertEqual(packets[0], "abcde".data(using: .utf8)!)
        XCTAssertEqual(packets[1], "fghij".data(using: .utf8)!)
        XCTAssertTrue(parser.buffer.isEmpty)

        parser.append(data: "klmnopqrstuvwxyz".data(using: .utf8)!)
        packets = parser.popReceivedPackets()
        XCTAssertEqual(packets.count, 3)
        XCTAssertEqual(packets[0], "klmno".data(using: .utf8)!)
        XCTAssertEqual(packets[1], "pqrst".data(using: .utf8)!)
        XCTAssertEqual(packets[2], "uvwxy".data(using: .utf8)!)
        XCTAssertEqual(parser.buffer, "z".data(using: .utf8)!)
    }
}
