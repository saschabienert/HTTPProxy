import UIKit

protocol RequestsListViewOutput: class {
    
    func requestSelected(_ request: HTTPRequest)
    func editFilter(_ filter: HTTPProxyFilter)
}

class RequestsListViewController: UIViewController {
    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var filterView: UIView!
    @IBOutlet private weak var filterViewHeight: NSLayoutConstraint!

    private lazy var contentVC = SearchableListViewController(nibName: "SearchableListViewController", bundle: HTTPProxyUI.bundle)
    private var filterVC: RequestFilterViewController!

    @IBOutlet private var newRequestNotification: UILabel!
    private var refreshControl = UIRefreshControl()

    var viewModel: RequestsListViewModel!
    weak var requestsListViewOutput: RequestsListViewOutput?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "iOS HTTP Proxy"
        view.backgroundColor = HTTPProxyUI.settings.colorScheme.backgroundColor
        
        contentVC.delegate = self
        addChild(contentVC)
        contentView.addSubview(contentVC.view)
        var frame = contentView.frame
        frame.origin = CGPoint.zero
        contentVC.view.frame = frame
        contentVC.didMove(toParent: self)

        viewModel.searchableListSection.bind { [weak self] section in
            if let section = section {
                self?.contentVC.loadSections([section])
            }
        }
        
        viewModel.filters.bind { [weak self] filters in
            self?.filterVC.loadFilters(filters)
        }
    }
    
    func clearRequests() {
        viewModel.clearRequest()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        guard let filterViewController = destination as? RequestFilterViewController else {
            fatalError("Unable to instantiate RequestFilterViewController")
        }
        filterVC = filterViewController
        filterVC.delegate = self
    }
    
    func addFilter(_ filter: HTTPProxyFilter) {
        viewModel.addFilter(filter)
    }
    
    func reloadFilters() {
        viewModel.reloadFilters()
    }
}

extension RequestsListViewController: RequestDetailsDelegate {
    func didSelectItem(at index: Int) {
        if let request = viewModel.request(at: index) {
            requestsListViewOutput?.requestSelected(request)
        }
    }
}

extension RequestsListViewController: RequestFilterViewControllerDelegate {
    func editFilter(_ filter: QuickFilter) {
        if let filter = filter as? HTTPProxyFilter {
            requestsListViewOutput?.editFilter(filter)
        }
    }
    
    func deleteFilter(_ filter: QuickFilter) {
        viewModel.deleteFilter(filter)
    }
    
    func filterDidUpdateHeight(_ height: CGFloat) {
        filterViewHeight.constant = height
        view.layoutIfNeeded()
    }
    
    func filterSelected(_ filter: QuickFilter) {
        viewModel.toggleFilter(filter)
    }
}
