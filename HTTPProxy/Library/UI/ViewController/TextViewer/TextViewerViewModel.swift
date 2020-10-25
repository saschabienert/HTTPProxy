import Foundation
import UIKit.UIColor

private struct FontSize {
    static let minimum = 8.0
    static let initial = 14.0
    static let maximum = 20.0
}

class TextViewerViewModel {

    let minimumFontSize = FontSize.minimum
    let maximumFontSize = FontSize.maximum
    var currentFontSize = FontSize.initial
    
    let text: String
    let filename: String
    let highlightedTextColor: UIColor
    
    let isProcessing = Observable<Bool>(false)
    let attributedText: Observable<NSAttributedString>
    let searchResultsCount: Observable<Int?>

    private var searchOperation: SearchOperation?
    private var originalHighlightedText: NSAttributedString?
    private let backgroundQueue = DispatchQueue.global(qos: .userInteractive)

    init(text: String, filename: String, highlightedTextColor: UIColor) {
        self.text = text
        self.filename = filename
        self.highlightedTextColor = highlightedTextColor
        let string = NSAttributedString(string: text)
        attributedText = Observable(string)
        searchResultsCount = Observable(nil)
        highlightText()
    }
    
    private func highlightText() {
        let text = self.text
        backgroundQueue.async { [weak self] in
            guard let highlightr = Highlightr() else {
                return
            }
            self?.isProcessing.value = true
            let theme = HTTPProxyUI.darkModeEnabled() ? "atom-one-dark" : "atom-one-light"
            highlightr.setTheme(to: theme)
            if let highlightedText = highlightr.highlight(text) {
                self?.attributedText.value = highlightedText
                self?.originalHighlightedText = highlightedText
            }
            self?.isProcessing.value = false
        }
    }
    
    func highlightSearchResults(_ text: String) {
        guard let attributedString = originalHighlightedText else {
            return
        }

        isProcessing.value = true
        searchOperation?.completion = nil
        searchOperation = nil
        
        if text.isEmpty {
            attributedText.value = attributedString
            searchResultsCount.value = nil
            isProcessing.value = false
            return
        }
        
        let operation = SearchOperation(attributedString: attributedString, text: text, color: self.highlightedTextColor)
        operation.completion = { [weak self] (string, count) in
            self?.searchOperation = nil
            DispatchQueue.main.async {
                self?.attributedText.value = string
                self?.searchResultsCount.value = count
                self?.isProcessing.value = false
            }
        }
        self.searchOperation = operation
        backgroundQueue.async {
            operation.execute()
        }
    }
}

class SearchOperation {
    
    let attributedString: NSAttributedString
    let text: String
    let color: UIColor
    var completion: ((NSAttributedString, Int) -> Void)?
    
    init(attributedString: NSAttributedString, text: String, color: UIColor) {
        self.attributedString = attributedString
        self.text = text
        self.color = color
    }
    
    func execute() {
        let text = self.text
        attributedString.highlight(text, highlightedTextColor: color) { [weak self] (string, count) in
            if let completion = self?.completion {
                completion(string, count)
            }
        }
    }
}
