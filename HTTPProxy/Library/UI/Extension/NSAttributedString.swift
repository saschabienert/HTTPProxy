import UIKit

extension NSAttributedString {

    func highlight(_ text: String,
                   highlightedTextColor: UIColor,
                   font: UIFont? = nil,
                   completion: @escaping (NSAttributedString, Int) -> Void) {
        guard let ranges = self.ranges(of: text) else {
            completion(self, 0)
            return
        }
        let highlightedText = self.emphasizeText(in: ranges, color: highlightedTextColor, font: font)
        completion(highlightedText, ranges.count)
    }
    
    private func ranges(of searchString: String) -> [NSRange]? {
        let str = self.string.lowercased()
        return str.ranges(of: searchString.lowercased())
    }
    
    private func emphasizeText(in ranges: [NSRange], color: UIColor, font: UIFont? = nil) -> NSAttributedString {
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
