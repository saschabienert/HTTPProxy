import UIKit

extension NSAttributedString {

    func ranges(of searchString: String) -> [NSRange]? {
        let str = self.string.lowercased()
        return str.ranges(of: searchString.lowercased())
    }
    
    func emphasizeText(in ranges: [NSRange], color: UIColor, font: UIFont? = nil) -> NSAttributedString {
        var attrs: [NSAttributedString.Key: Any] = [.backgroundColor: color]
        if font != nil {
            attrs[NSAttributedString.Key.font] = font
        }

        let attributedText = NSMutableAttributedString(attributedString: self)
        for range in ranges {
            attributedText.addAttributes(attrs, range: range)
        }
        return attributedText
    }
}
