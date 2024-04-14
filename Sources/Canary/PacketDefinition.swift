//
//  PacketDefinition.swift
//  
//
//  Created by Andrew R Madsen on 4/13/24.
//

import Foundation

public enum PacketDefinition {
    case evaluated((Data) -> Bool)
    case rangeDelimited(prefix: Data, suffix: Data)
    case endDelimited(Data)
    case fixedLength(Int)
}

public extension PacketDefinition {
    static func rangeDelimited(prefix: String, suffix: String) -> PacketDefinition {
        .rangeDelimited(prefix: prefix.data(using: .utf8)!,
                        suffix: suffix.data(using: .utf8)!)
    }

    static func endDelimited(_ suffix: String) -> PacketDefinition {
        .endDelimited(suffix.data(using: .utf8)!)
    }
}
