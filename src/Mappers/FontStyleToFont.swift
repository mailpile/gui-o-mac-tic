import AppKit

class FontStyleToFontMapper {
    static func map(_ fontStyle: FontStyles.FontStyle) -> NSFont {
        let pointSize: CGFloat = fontStyle.points != nil
            ? CGFloat(fontStyle.points!)
            : Constants.DEFAULT_FONT_SIZE
        var font = NSFont.userFont(ofSize: pointSize)!
        
        if fontStyle.family != nil {
            font = NSFontManager.shared.convert(font, toFamily: fontStyle.family!)
        }
        if fontStyle.bold == true {
            font = NSFontManager.shared.convert(font, toHaveTrait: NSFontTraitMask.boldFontMask)
        }
        if fontStyle.italic == true {
            font = NSFontManager.shared.convert(font, toHaveTrait: NSFontTraitMask.italicFontMask)
        }
        return font
    }
}
