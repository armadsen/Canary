//
//  PacketParser.swift
//
//
//  Created by Andrew R Madsen on 4/13/24.
//

import Foundation

public class PacketParser {

    public init(_ definition: PacketDefinition) {
        self.definition = definition
    }

    // MARK: - Public Methods

    public func append(_ data: Data) {
        buffer.append(data)
    }

    public func append(_ string: String) {
        append(string.data(using: .utf8)!)
    }

    public func packetsByAppending(_ data: Data) -> [Data] {
        append(data)
        return popReceivedPackets()
    }

    public func packetsByAppending(_ string: String) -> [Data] {
        append(string)
        return popReceivedPackets()
    }

    public func popReceivedPackets() -> [Data] {
        switch definition {
        case .evaluated(let evaluator):
            return packetsUsing(evaluator: evaluator)
        case .rangeDelimited(let prefix, let suffix):
            return packetsUsingDelimiters(prefix: prefix, suffix: suffix)
        case .fixed(let suffix),
             .endDelimited(let suffix):
            var packets = buffer
                .split(separator: suffix)
            if !buffer.hasSuffix(suffix) {
                buffer = packets.popLast() ?? Data()
            } else {
                buffer.removeAll()
            }
            return packets.map { $0 + suffix }
        case .fixedLength(let length):
            var result = [Data]()
            while buffer.count >= length {
                let start = buffer.startIndex
                let end = start.advanced(by: length)
                let packet = buffer.subdata(in: start..<end)
                result.append(packet)
                buffer.removeSubrange(start..<end)
            }
            return result
        }
    }

    public func clearBuffer() {
        buffer.removeAll()
    }

    // MARK: - Public Properties

    public let definition: PacketDefinition

    public private(set) var buffer = Data()

    // MARK: - Private Methods

    private func packetsUsingDelimiters(prefix: Data, suffix: Data) -> [Data] {
        guard buffer.count > 0 else {
            return []
        }

        var result = [Data]()
        var hasPrefix = false
        var scratch = buffer
        var packetBuffer = Data()
        while let byte = scratch.popFirst() {
            packetBuffer.append(byte)
            if packetBuffer.hasSuffix(prefix) {
                packetBuffer = prefix
                hasPrefix = true
            }
            if packetBuffer.hasSuffix(suffix), hasPrefix {
                result.append(packetBuffer)
                hasPrefix = false
                packetBuffer.removeAll()
            }
        }
        buffer = packetBuffer
        return result
    }

    private func packetsUsing(evaluator: (Data) -> Bool) -> [Data] {

        guard buffer.count > 0 else {
            return []
        }

        func validPacketAtEnd(of buffer: Data, using evaluator: (Data) -> Bool) -> Data? {
            for i in (1...buffer.count) {
                let subPacket = buffer.suffix(i)
                if evaluator(subPacket) {
                    return subPacket
                }
            }
            return nil
        }

        var scratch = Data()
        var result = [Data]()
        for byte in buffer {
            scratch.append(byte)
            if let packet = validPacketAtEnd(of: scratch, using: evaluator) {
                result.append(packet)
                scratch.removeAll()
            }
        }
        buffer = scratch
        return result
    }

    // MARK: - Private Properties
}

public extension PacketParser {
    convenience init(_ data: Data) {
        self.init(.fixed(data))
    }

    convenience init(_ string: String) {
        self.init(Data(string.utf8))
    }
}
