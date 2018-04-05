import Foundation

extension UInt16 {
    static func random(min: UInt16, max: UInt16) -> UInt16 {
        precondition(min <= max, "max must be larger or equal to min.")
        return UInt16(arc4random_uniform(UInt32(max)-UInt32(min)) + UInt32(min))
    }
}
