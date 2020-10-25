import Foundation

class RequestsListViewModel {
    
    private var source: [HTTPRequest] = []
    private var filteredSource: [HTTPRequest] = []
    let filters: Observable<[HTTPProxyFilter]>
    let searchableListSection: Observable<SearchableListSection?>

    init() {
        source = HTTPProxy.shared.requests
        filters = Observable(HTTPProxy.shared.filters)
        searchableListSection = Observable(nil)
        HTTPProxy.shared.internalDelegate = self

        showFilteredRequests()
    }
    
    func showFilteredRequests() {
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
    
    func deleteFilter(_ filter: HTTPProxyFilter) {
        if let index = filters.value.firstIndex(where: { aFilter -> Bool in
               aFilter === filter
           }) {
            filters.value.remove(at: index)
            showFilteredRequests()
        }
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
