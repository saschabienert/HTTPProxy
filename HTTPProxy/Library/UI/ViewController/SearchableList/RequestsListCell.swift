import UIKit

class RequestsListCell: UITableViewCell {
    
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var titleLabel: SelectableLabel!
    @IBOutlet private var methodLabel: RoundedLabel!
    @IBOutlet private var statusLabel: RoundedLabel!
    @IBOutlet private var customLabel: RoundedLabel!
    @IBOutlet private var contentLabel: SelectableLabel!
    @IBOutlet private var activityView: UIActivityIndicatorView!
    private var viewModel: RequestsListCellViewModel!
    private let settings = HTTPProxyUI.settings

    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        containerView.backgroundColor = settings.colorScheme.foregroundColor
        containerView.layer.cornerRadius = 8
        
        let boldFont = settings.regularBoldFont
        titleLabel.font = boldFont
        titleLabel.textColor = settings.colorScheme.secondaryTextColor
        
        methodLabel.font = boldFont
        statusLabel.font = boldFont

        customLabel.font = settings.regularFont
        customLabel.backgroundColor = settings.colorScheme.selectedColor
        customLabel.textColor = .white
        
        activityView.color = settings.colorScheme.primaryTextColor
    }
    
    func configure(with searchableListItem: SearchableListItem) {
        
        self.viewModel = RequestsListCellViewModel(searchableListItem: searchableListItem)
        
        viewModel.key.bind { [weak self] (key) in
            self?.titleLabel.attributedText = key
        }
        
        viewModel.value.bind { [weak self] (value) in
            self?.contentLabel.attributedText = value
        }

        viewModel.customText.bind { [weak self] (value) in
            self?.customLabel.isHidden = value == nil
            self?.customLabel.text = value
        }

        viewModel.method.bind { [weak self] (method) in
            if let method = method {
                self?.methodLabel.text = method
                self?.methodLabel.backgroundColor = .white
                self?.methodLabel.textColor = .black
                self?.methodLabel.isHidden = false
            } else {
                self?.methodLabel.isHidden = true
            }
        }
        
        viewModel.requestStatus.bind { [weak self] (requestStatus) in
            self?.updateStatusLabel(requestStatus: requestStatus)
        }
    }
    
    func emphasize(text: String) {
        viewModel.emphasize(text: text)
    }
    
    private func updateStatusLabel(requestStatus: RequestStatus?) {
        if let requestStatus = requestStatus {
            switch requestStatus {
            case .completed(let statusCode):
                let color = (statusCode >= 200 && statusCode < 300) ? settings.colorScheme.semanticColorPositive : settings.colorScheme.semanticColorNegative
                statusLabel.backgroundColor = color
                statusLabel.text = "\(statusCode)"
                statusLabel.isHidden = false
                activityView.isHidden = true
            case .error:
                statusLabel.backgroundColor = settings.colorScheme.semanticColorNegative
                statusLabel.text = "Error"
                statusLabel.isHidden = false
                activityView.isHidden = true
            default:
                statusLabel.isHidden = true
                activityView.isHidden = false
                activityView.startAnimating()
            }
        } else {
            statusLabel.isHidden = true
            activityView.isHidden = true
        }
    }
}
