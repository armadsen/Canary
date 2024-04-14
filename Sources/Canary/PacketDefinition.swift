//
//  PacketDefinition.swift
//  
//
//  Created by Andrew R Madsen on 4/13/24.
//

import Foundation

public enum PacketDefinition {
    case evaluated((Data) -> Bool)
    case rangeDelimited(Data, Data) // First Data is prefix, second is suffix
    case endDelimited(Data)
    case fixedLength(Int)
}
