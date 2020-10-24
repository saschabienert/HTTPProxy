import UIKit

protocol RequestsListViewOutput {
    
    func viewLoaded()
    func requestSelected(_ request: HTTPRequest)
    func editFilter(_ filter: HTTPProxyFilter)
    func deleteFilter(_ filter: HTTPProxyFilter)
}

class RequestsListViewController: UIViewController {
    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var filterView: UIView!
    @IBOutlet private weak var filterViewHeight: NSLayoutConstraint!

    private lazy var contentVC = SearchableListViewController(nibName: "SearchableListViewController", bundle: HTTPProxyUI.bundle)
    private var filterVC: RequestFilterViewController!

    @IBOutlet private var newRequestNotification: UILabel!
    private var refreshControl = UIRefreshControl()

    private var source: [HTTPRequest] = []
    private var filteredSource: [HTTPRequest] = []
    var filters: [HTTPProxyFilter] = []
    var requestsListViewOutput: RequestsListViewOutput?

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

        requestsListViewOutput?.viewLoaded()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        guard let filterViewController = destination as? RequestFilterViewController else {
            fatalError("Unable to instantiate RequestFilterViewController")
        }
        filterVC = filterViewController
        filterVC.delegate = self
    }
    
    func loadFilters(_ filters: [HTTPProxyFilter]) {
        self.filters = filters
        filterVC.loadFilters(filters)
        showFilteredRequests()
    }
    
    func loadRequests(_ requests: [HTTPRequest]) {
        source = requests
        showFilteredRequests()
    }
    
    func showFilteredRequests() {
        filteredSource = RequestListFilter().filterRequests(source, with: filters)

        var requestModels: [RequestViewModel] = []
        for request in filteredSource {
            let viewModel = RequestViewModel(request: request)
            requestModels.append(viewModel)
        }
        
        let filterEnabled = filters.contains { (filter) -> Bool in
            filter.enabled
        }
        let totalCount = filterEnabled ? source.count : nil
        let section = SearchableListSection(items: requestModels, title: "Requests", totalCount: totalCount)
        contentVC.loadSections([section])
    }
}

extension RequestsListViewController: RequestDetailsDelegate {
    func didSelectItem(at index: Int) {
        let request = filteredSource[index]
        requestsListViewOutput?.requestSelected(request)
    }
}

extension RequestsListViewController: RequestFilterViewControllerDelegate {
    func editFilter(_ filter: HTTPProxyFilter) {
        requestsListViewOutput?.editFilter(filter)
    }
    
    func deleteFilter(_ filter: HTTPProxyFilter) {
        requestsListViewOutput?.deleteFilter(filter)
    }
    
    func filterDidUpdateHeight(_ height: CGFloat) {
        filterViewHeight.constant = height
        view.layoutIfNeeded()
    }
    
    func filterSelected(_ filter: HTTPProxyFilter) {
        filter.enabled = !filter.enabled
        showFilteredRequests()
    }
}
