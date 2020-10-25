import Foundation
import UIKit.NSParagraphStyle

class RequestsListCellViewModel {
    
    private let searchableListItem: SearchableListItem
    let key: Observable<NSAttributedString>
    let value: Observable<NSAttributedString>
    let method: Observable<String?>
    let requestStatus: Observable<RequestStatus?>

    init(searchableListItem: SearchableListItem) {
        self.searchableListItem = searchableListItem
        key = Observable(RequestsListCellViewModel.formattedKey(searchableListItem.key))
        value = Observable(RequestsListCellViewModel.formattedValue(searchableListItem.value))
        method = Observable(searchableListItem.method)
        requestStatus = Observable(searchableListItem.requestStatus)
    }

    func emphasize(text: String) {
        let color = HTTPProxyUI.settings.colorScheme.highlightedTextColor
        let font = HTTPProxyUI.settings.regularBoldFont
        key.value.highlight(text, highlightedTextColor: color, font: font) { [weak self] (attributedString, _) in
            self?.key.value = attributedString
        }
        value.value.highlight(text, highlightedTextColor: color, font: font) { [weak self] (attributedString, _) in
            self?.value.value = attributedString
        }
    }

    private static func formattedKey(_ key: String) -> NSAttributedString {
        let attributes = [
            NSAttributedString.Key.font: HTTPProxyUI.settings.regularBoldFont,
            NSAttributedString.Key.foregroundColor: HTTPProxyUI.settings.colorScheme.secondaryTextColor
        ]
        return NSAttributedString(string: "\(key)", attributes: attributes)
    }
    
    private static func formattedValue(_ value: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byCharWrapping
        
        let attributes = [
            NSAttributedString.Key.font: HTTPProxyUI.settings.regularFont,
            NSAttributedString.Key.foregroundColor: HTTPProxyUI.settings.colorScheme.primaryTextColor,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
        return NSAttributedString(string: "\(value)", attributes: attributes)
    }
}
