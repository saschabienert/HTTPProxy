import UIKit

protocol EditFilterViewControllerDelegate: class {
    func editFilterViewController(_ viewController: EditFilterViewController, didEditFilter filter: HTTPProxyFilter)
}

class EditFilterViewController: UIViewController {

    var filter: HTTPProxyFilter?
    weak var delegate: EditFilterViewControllerDelegate?
    
    @IBOutlet private var backgroundViews: [RoundedView]!
    @IBOutlet private var labels: [UILabel]!
    @IBOutlet private var textFields: [UITextField]!

    @IBOutlet private var nameTextField: UITextField!
    @IBOutlet private var httpMethodTextField: UITextField!
    @IBOutlet private var schemeTextField: UITextField!
    @IBOutlet private var hostTextField: UITextField!
    @IBOutlet private var portTextField: UITextField!
    @IBOutlet private var queryItemsTextField: UITextField!
    @IBOutlet private var headerFieldsTextField: UITextField!

    @IBOutlet weak var tableViewBottomLayoutConstraint: NSLayoutConstraint!
    private var tableViewBottonInset: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem = saveButton

        setupView()
        tableViewBottonInset = tableViewBottomLayoutConstraint.constant

        if let filter = filter {
            title = "Edit Filter"
            loadView(filter: filter)
        } else {
            title = "New Filter"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    private func keyboardWillAppear(notification: NSNotification?) {

        guard let keyboardFrame = notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let bottomInset: CGFloat
        if #available(iOS 11.0, *) {
            bottomInset = keyboardFrame.cgRectValue.height - UIApplication.shared.keyWindow!.safeAreaInsets.bottom
        } else {
            bottomInset = keyboardFrame.cgRectValue.height
        }

        tableViewBottomLayoutConstraint.constant = -bottomInset
    }

    @objc
    private func keyboardWillDisappear(notification: NSNotification?) {
        tableViewBottomLayoutConstraint.constant = tableViewBottonInset
    }
    
    @objc func save() {
        guard let name = nameTextField.validText() else {
            showError(message: "Field 'name' cannot be empty")
            return
        }
        let requestFilter = filter?.requestFilter ?? RequestFilter()
        requestFilter.scheme = schemeTextField.validText()
        if let scheme = requestFilter.scheme {
            if !(scheme == "http" || scheme == "https") {
                showError(message: "Invalid value for field 'scheme'. Supported values: 'http' or 'https'")
                return
            }
        }
        requestFilter.httpMethod = httpMethodTextField.validText()
        requestFilter.host = hostTextField.validText()
        var port: Int?
        if let portText = portTextField.validText() {
            port = Int(portText)
        }
        requestFilter.port = port
        
        if let queryItems = queryItemsTextField.validText() {
            let pairs = queryItems.keyValuePairs()
            requestFilter.queryItems = pairs
        }
        
        if let headerFields = headerFieldsTextField.validText() {
            let pairs = headerFields.keyValuePairs()
            requestFilter.headerFields = pairs
        }
        
        if let filter = filter {
            filter.name = name
            delegate?.editFilterViewController(self, didEditFilter: filter)
        } else {
            let filter = HTTPProxyFilter(name: name, requestFilter: requestFilter)
            delegate?.editFilterViewController(self, didEditFilter: filter)
        }
    }
    
    private func setupView() {
        view.backgroundColor = HTTPProxyUI.settings.colorScheme.backgroundColor
        backgroundViews.forEach { (view) in
            view.backgroundColor = HTTPProxyUI.settings.colorScheme.foregroundColor
        }
        
        let boldFont = HTTPProxyUI.settings.regularBoldFont
        labels.forEach { (label) in
            label.font = boldFont
            label.textColor = HTTPProxyUI.settings.colorScheme.secondaryTextColor
        }
        
        textFields.forEach { (textField) in
            textField.autocorrectionType = .no
            textField.font = HTTPProxyUI.settings.regularBoldFont
            textField.textColor = HTTPProxyUI.settings.colorScheme.primaryTextColor
            textField.delegate = self
        }
    }
    
    private func loadView(filter: HTTPProxyFilter) {
        nameTextField.text = filter.name
        schemeTextField.text = filter.requestFilter.scheme
        httpMethodTextField.text = filter.requestFilter.httpMethod
        
        if let host = filter.requestFilter.host {
            hostTextField.text = host
        }
        
        if let port = filter.requestFilter.port {
            portTextField.text = "\(port)"
        }
        
        queryItemsTextField.text = filter.requestFilter.queryItems?.toString()
        headerFieldsTextField.text = filter.requestFilter.headerFields?.toString()
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .actionSheet)
        present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
}

extension Array where Element == KeyValuePair {
    func toString() -> String? {
        let components = self.map { (pair) -> String in
            return "\(pair.key)=\(pair.value ?? "")"
        }
        return components.joined(separator: "&")
    }
}

extension EditFilterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UITextField {
    func validText() -> String? {
        if let text = self.text {
            let timmedString = text.trimmingCharacters(in: .whitespacesAndNewlines)
            return timmedString.count > 0 ? timmedString : nil
        }
        return nil
    }
}

extension String {
    
    func keyValuePairs() -> [KeyValuePair]? {
        if self.starts(with: "&") {
              return nil
        }
        let pairs = self.split(separator: "&")
        if pairs.count > 0 {
            var queryItems: [KeyValuePair] = []
            for substring in pairs {
                guard let pair = String(substring).keyValuePair() else {
                    return nil
                }
                queryItems.append(pair)
            }
            return queryItems
        }
        return nil
    }
    
    private func keyValuePair() -> KeyValuePair? {
        if self.starts(with: "=") || (self.firstIndex(of: "=") != self.lastIndex(of: "=")) {
            return nil
        }
        let pairComponents = self.split(separator: "=")
        guard let name = pairComponents.first else {
            return nil
        }
        var value: String?
        if pairComponents.count == 2, let str = pairComponents.last {
            value = String(str)
        }
        return KeyValuePair(String(name), value)
    }
}
