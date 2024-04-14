//
//  Data+PrefixSuffix.swift
//
//
//  Created by Andrew R Madsen on 4/13/24.
//

import Foundation

internal extension Data {
    func hasPrefix(_ data: Data) -> Bool {
        guard self.count >= data.count else {
            return false
        }

        let myStart = self.startIndex
        let otherStart = data.startIndex
        for i in 0..<Swift.min(self.count, data.count) {
            let byte1 = self[myStart.advanced(by: i)]
            let byte2 = data[otherStart.advanced(by: i)]
            if byte1 != byte2 {
                return false
            }
        }
        return true
    }

    func hasSuffix(_ data: Data) -> Bool {
        guard count >= data.count else {
            return false
        }

        return self.suffix(data.count).hasPrefix(data)
    }
}
