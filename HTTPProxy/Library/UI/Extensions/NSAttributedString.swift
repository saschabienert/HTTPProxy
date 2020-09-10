import UIKit

extension NSAttributedString {

    func emphasizeText(_ text: String, color: UIColor, font: UIFont? = nil) -> NSAttributedString {
        guard let ranges = self.string.lowercased().ranges(of: text.lowercased()) else {
            return self
        }

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
