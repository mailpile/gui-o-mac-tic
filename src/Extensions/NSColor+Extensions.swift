import AppKit

extension NSColor {
    
    convenience init(hexColour: String) {
        var hex: String = hexColour.hasPrefix("#") ? String(hexColour.dropFirst()) : hexColour
        guard hex.isHex() && (hex.count == 6 || hex.count == 3) else {
            preconditionFailure("The string \(hexColour) does not represent a hex colour.")
        }
        
        func convert3DigitColourTo6DigitColour(_ threeDigitHex: String) -> Int32 {
            let decimalValue = Int32(hex, radix: 16)!
            var digit = [Int32](repeating: 0, count: 6)
            digit[0] = (decimalValue & 0xF00) << 0xC
            digit[1] = digit[0] >> 0x4
            digit[2] = (decimalValue & 0xF0) << 0x8
            digit[3] = digit[2] >> 0x4
            digit[4] = (decimalValue & 0xF) << 0x4
            digit[5] = digit[4] >> 0x4
            return digit.reduce(0, |)
        }
        
        let number = hex.count == 3
            ? convert3DigitColourTo6DigitColour(hex)
            : Int32(hex, radix: 16)!
        
        let red = CGFloat((number & 0xFF0000) >> 0x10) / 0xFF
        let green = CGFloat((number & 0xFF00) >> 0x8) / 0xFF
        let blue = CGFloat(number & 0xFF) / 0xFF
        
        self.init(red: red, green: green, blue: blue, alpha: CGFloat(1))
    }
}
