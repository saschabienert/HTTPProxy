import Foundation
import UIKit.UIColor

private struct FontSize {
    static let minimum = 8.0
    static let initial = 14.0
    static let maximum = 20.0
}

class TextViewerViewModel {

    let minimunFontSize = FontSize.minimum
    let maximunFontSize = FontSize.maximum
    var currentFontSize = FontSize.initial
    
    let text: String
    let filename: String
    let highlightedTextColor: UIColor
    
    let isProcessing = Observable<Bool>(false)
    let syntaxHighlightedText: Observable<NSAttributedString>
    let searchResultsCount: Observable<Int?>

    private var searchWorkItem: DispatchWorkItem?
    private var originalHighlightedText: NSAttributedString?

    init(text: String, filename: String, highlightedTextColor: UIColor) {
        self.text = text
        self.filename = filename
        self.highlightedTextColor = highlightedTextColor
        let string = NSAttributedString(string: text)
        syntaxHighlightedText = Observable(string)
        searchResultsCount = Observable(nil)
        highlightText()
    }
    
    private func highlightText() {
        guard let highlightr = Highlightr() else {
            return
        }
        isProcessing.value = true
        let theme = HTTPProxyUI.darkModeEnabled() ? "atom-one-dark" : "atom-one-light"
        highlightr.setTheme(to: theme)
        DispatchQueue.global(qos: .userInteractive).async {
            if let highlightedText = highlightr.highlight(self.text) {
                self.syntaxHighlightedText.value = highlightedText
                self.originalHighlightedText = highlightedText
            }
            self.isProcessing.value = false
        }
    }
    
    func highlightSearchResults(_ text: String) {
        guard let attributedString = originalHighlightedText else {
            return
        }
        
        isProcessing.value = true
        searchWorkItem?.cancel()
        
        if text.isEmpty {
            syntaxHighlightedText.value = attributedString
            searchResultsCount.value = nil
            isProcessing.value = false
            return
        }
        
        let color = self.highlightedTextColor
        let requestWorkItem = DispatchWorkItem { [weak self] in
            attributedString.highlight(text, highlightedTextColor: color) { (string, count) in
                DispatchQueue.main.async {
                    self?.syntaxHighlightedText.value = string
                    self?.searchResultsCount.value = count
                    self?.isProcessing.value = false
                }
            }
        }
        
        searchWorkItem = requestWorkItem
        DispatchQueue
            .global(qos: .userInteractive)
            .asyncAfter(deadline: .now() + .milliseconds(500), execute: requestWorkItem)
    }
    
}

extension NSAttributedString {
    
    func highlight(_ text: String, highlightedTextColor: UIColor, completion: @escaping (NSAttributedString, Int) -> Void) {
        guard let ranges = self.ranges(of: text) else {
            completion(self, 0)
            return
        }
        let highlightedText = self.emphasizeText(in: ranges, color: highlightedTextColor)
        completion(highlightedText, ranges.count)
    }
}
