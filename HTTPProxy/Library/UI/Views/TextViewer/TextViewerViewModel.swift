import Foundation

private struct FontSize {
    static let minimum = 8.0
    static let initial = 14.0
    static let maximum = 20.0
}

class TextViewerViewModel {

    let minimunFontSize = FontSize.minimum
    let maximunFontSize = FontSize.maximum
    var currentFontSize = FontSize.initial
    
    private(set) var text: String
    private(set) var filename: String
    let isProcessing = Observable<Bool>(false)
    let syntaxHighlightedText: Observable<NSAttributedString>
    private(set) var searchResultsCount: Observable<Int?>
    private var searchWorkItem: DispatchWorkItem?
    private var originalHighlightedText: NSAttributedString?

    init(text: String, filename: String) {
        self.text = text
        self.filename = filename
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

        NSLog("cancelling")
        searchWorkItem?.cancel()
        
        if text.isEmpty {
            syntaxHighlightedText.value = attributedString
            searchResultsCount.value = nil
            isProcessing.value = false
            return
        }
        
        let requestWorkItem = DispatchWorkItem { [weak self] in
            NSLog("starting search \(text)")
            self?.highlight(text, in: attributedString) { [weak self] (string, count) in
                NSLog("completed search \(text)")
                DispatchQueue.main.async {
                    NSLog("return search \(text)")
                    self?.syntaxHighlightedText.value = string
                    self?.searchResultsCount.value = count
                    self?.isProcessing.value = false
                }
            }
        }
        
        NSLog("queuing search \(text)")
        searchWorkItem = requestWorkItem
        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + .milliseconds(500), execute: requestWorkItem)
    }
    
    private func highlight(_ text: String, in string: NSAttributedString, completion: @escaping (NSAttributedString, Int) -> Void) {
        NSLog("highlight \(text)")

        DispatchQueue.global().async {
            guard let ranges = string.ranges(of: text) else {
                completion(string, 0)
                return
            }
            let highlightedText = string.emphasizeText(in: ranges, color: HTTPProxyUI.colorScheme.highlightedTextColor)
            completion(highlightedText, ranges.count)
        }
    }
}
