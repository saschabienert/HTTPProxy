import Highlightr
import UIKit

struct FontSize {
    static let minimun = 8.0
    static let initial = 14.0
    static let maximum = 20.0
}

class TextViewerViewController: UIViewController {

    @IBOutlet private var textView: UITextView!
    @IBOutlet private var toolbar: UIToolbar!
    @IBOutlet private var stepper: UIStepper!
    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var searchResultsLabel: UILabel!
    
    private var text: String
    private var filename: String
    private var syntaxHighlightedText: NSAttributedString?
    
    init(text: String, filename: String) {
        self.text = text
        self.filename = filename
        super.init(nibName: String(describing: TextViewerViewController.self), bundle: HTTPProxyUI.bundle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = filename
        searchResultsLabel.backgroundColor = HTTPProxyUI.colorScheme.foregroundColor
        toolbar.tintColor = HTTPProxyUI.colorScheme.primaryTextColor
        toolbar.barTintColor = HTTPProxyUI.colorScheme.foregroundColor
        stepper.minimumValue = FontSize.minimun
        stepper.maximumValue = FontSize.maximum
        stepper.value = FontSize.initial
        
        searchResultsLabel.font = UIFont.menlo14
        clearResultCount()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        searchBar.barTintColor = HTTPProxyUI.colorScheme.foregroundColor
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.placeholder = "Search"
            searchBar.searchTextField.backgroundColor = HTTPProxyUI.colorScheme.backgroundColor
            searchBar.searchTextField.textColor = HTTPProxyUI.colorScheme.primaryTextColor
        } else {
            let attributes = [NSAttributedString.Key.foregroundColor: HTTPProxyUI.colorScheme.primaryTextColor]
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = attributes
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let activityIndicator = UIActivityIndicatorView(frame: textView.frame)
        if #available(iOS 13.0, *) {
            activityIndicator.style = .large
        }
        activityIndicator.color = HTTPProxyUI.colorScheme.primaryTextColor
        textView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        highlightedText(text) { highlightedText in
            self.syntaxHighlightedText = highlightedText
            DispatchQueue.main.async {
                self.textView.attributedText = highlightedText
                self.setFontSize(FontSize.initial)
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        }
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
        } else {
            var bottomInset = keyboardFrame.height
            if #available(iOS 11.0, *) {
                bottomInset -= view.safeAreaInsets.bottom
            }
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)

        }
        textView.scrollIndicatorInsets = textView.contentInset

        //let selectedRange = textView.selectedRange
        //textView.scrollRangeToVisible(selectedRange)
    }
    
    private func highlightSearchResults(_ text: String) {
        guard let attributedString = syntaxHighlightedText else {
            return
        }
        
        if text.isEmpty {
            clearResultCount()
            setText(text: attributedString)
            return
        }
        
        guard let ranges = attributedString.ranges(of: text) else {
            displayResultCount(0)
            return
        }
        
        displayResultCount(ranges.count)
        let highlightedText = attributedString.emphasizeText(in: ranges, color: HTTPProxyUI.colorScheme.highlightedTextColor)
        setText(text: highlightedText)
    }
    
    func setText(text: NSAttributedString) {
        let font = textView.font
        textView.attributedText = text
        textView.font = font
    }
    
    private func resultCount(_ count: Int) -> String {
        switch count {
        case 0:
            return "No results"
        case 1:
            return "1 result"
        default:
            return "\(count) results"
        }
    }
    
    private func clearResultCount() {
        searchResultsLabel.text = ""
    }
    
    private func displayResultCount(_ count: Int) {
        searchResultsLabel.text = resultCount(count)
    }
    
    private func highlightedText(_ text: String, completionHandler: @escaping (NSAttributedString?) -> Void) {
        if let highlightr = Highlightr() {
            let theme = HTTPProxyUI.darkModeEnabled() ? "atom-one-dark" : "atom-one-light"
            highlightr.setTheme(to: theme)
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1, execute: {
                let highlightedText = highlightr.highlight(text)
                completionHandler(highlightedText)
            })
        }
    }
    
    @IBAction private func share() {
        let activityItems = [textView.text]
        let activityController = UIActivityViewController(activityItems: activityItems as [Any], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
    @IBAction private func copyText() {
        UIPasteboard.general.string = textView.text
    }
    
    @IBAction private func changeFont(_ sender: UIStepper) {
        setFontSize(sender.value)
    }
    
    private func setFontSize(_ size: Double) {
        guard let font = textView.font else {
            return
        }
        let newFont = font.withSize(CGFloat(size))
        textView.font = newFont
    }
}

extension TextViewerViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        highlightSearchResults(searchText)
    }
}
