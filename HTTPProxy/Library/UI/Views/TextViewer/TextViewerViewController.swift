import UIKit

class TextViewerViewController: UIViewController {

    @IBOutlet private var textView: UITextView!
    @IBOutlet private var toolbar: UIToolbar!
    @IBOutlet private var stepper: UIStepper!
    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var searchResultsLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    private let viewModel: TextViewerViewModel
    
    init(text: String, filename: String) {
        viewModel = TextViewerViewModel(
            text: text,
            filename: filename,
            highlightedTextColor: HTTPProxyUI.colorScheme.highlightedTextColor)
        super.init(nibName: String(describing: TextViewerViewController.self), bundle: HTTPProxyUI.bundle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = viewModel.filename
        searchResultsLabel.backgroundColor = HTTPProxyUI.colorScheme.foregroundColor
        toolbar.tintColor = HTTPProxyUI.colorScheme.primaryTextColor
        toolbar.barTintColor = HTTPProxyUI.colorScheme.foregroundColor
        stepper.minimumValue = viewModel.minimumFontSize
        stepper.maximumValue = viewModel.maximumFontSize
        stepper.value = viewModel.currentFontSize
        
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

        activityIndicator.color = HTTPProxyUI.colorScheme.primaryTextColor

        setupBindings()
    }

    func setupBindings() {
        viewModel.isProcessing.bind { [weak self] (isProcessing) in
            NSLog("\(isProcessing)")
            DispatchQueue.main.async {
                if isProcessing {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
        
        viewModel.attributedText.bind { [weak self] (string) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.textView.attributedText = string
                self.setFontSize(self.viewModel.currentFontSize)
            }
        }
        
        viewModel.searchResultsCount.bind { [weak self] (count) in
            DispatchQueue.main.async {
                if let count = count {
                    self?.displayResultCount(count)
                } else {
                    self?.clearResultCount()
                }
            }
        }
    }
    
    @objc private func adjustForKeyboard(notification: Notification) {
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
            if let superviewHeight = textView.superview?.frame.size.height {
                let bottomSpacing = superviewHeight - (textView.frame.height + textView.frame.origin.y)
                bottomInset -= bottomSpacing
            }
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        }
        textView.scrollIndicatorInsets = textView.contentInset
    }

    private func setText(text: NSAttributedString) {
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
        viewModel.currentFontSize = size
        let newFont = font.withSize(CGFloat(size))
        textView.font = newFont
    }
}

extension TextViewerViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.highlightSearchResults(searchText)
    }
}
