import Foundation

class RequestsListViewModel {
    
    private var source: [HTTPRequest] = []
    private var filteredSource: [HTTPRequest] = []
    let filters: Observable<[QuickFilter]>
    let searchableListSection: Observable<SearchableListSection?>

    init() {
        source = HTTPProxy.shared.requests
        filters = Observable(HTTPProxy.shared.filters)
        searchableListSection = Observable(nil)

        HTTPProxy.shared.internalDelegate = self
        showFilteredRequests()
    }
    
    private func showFilteredRequests() {
        let allFilters = filters.value
        filteredSource = RequestListFilter().filterRequests(source, with: allFilters)

        var requestModels: [RequestViewModel] = []
        for request in filteredSource {
            let viewModel = RequestViewModel(request: request)
            requestModels.append(viewModel)
        }
        
        let filterEnabled = allFilters.contains { $0.enabled }
        let totalCount = filterEnabled ? source.count : nil
        let section = SearchableListSection(items: requestModels, title: "Requests", totalCount: totalCount)
        searchableListSection.value = section
    }
    
    func clearRequest() {
        HTTPProxy.shared.clearRequests()
        reloadRequests()
    }
    
    func request(at index: Int) -> HTTPRequest? {
        if index >= filteredSource.count {
            return nil
        }
        let request = filteredSource[index]
        return request
    }
    
    private func reloadRequests() {
        source = HTTPProxy.shared.requests
        showFilteredRequests()
    }
    
    func reloadFilters() {
        filters.value = HTTPProxy.shared.filters
        showFilteredRequests()
    }
    
    func addFilter(_ filter: QuickFilter) {
        HTTPProxy.shared.filters.append(filter)
        reloadFilters()
    }
    
    func toggleFilter(_ filter: QuickFilter) {
        if let selectedFilter = HTTPProxy.shared.filters.first(where: { $0 === filter }) {
            selectedFilter.enabled = !filter.enabled
        }
        reloadFilters()
    }
    
    func deleteFilter(_ filter: QuickFilter) {
        if let index = HTTPProxy.shared.filters.firstIndex(where: { $0 === filter }) {
            HTTPProxy.shared.filters.remove(at: index)
        }
        reloadFilters()
    }
}

extension RequestsListViewModel: HTTPProxyDelegate {

    func shouldFireURLRequest(_ urlRequest: URLRequest) -> Bool {
        return true
    }
    
    func willFireRequest(_ httpRequest: HTTPRequest) {
        reloadRequests()
    }
    
    func didCompleteRequest(_ httpRequest: HTTPRequest) {
        reloadRequests()
    }
}
