import Foundation

struct RequestListFilter {
    
    func filterRequests(_ requests: [HTTPRequest], with filters: [QuickFilter]) -> [HTTPRequest] {
        let enabledFilters = filters.filter({ filter -> Bool in
            filter.enabled
        })
        
        if enabledFilters.count == 0 {
            return requests
        }
        
        let filteredRequests = requests.filter { (request) -> Bool in
            for filter in enabledFilters {
                if filter.matchesRequest(request.request) {
                    return true
                }
            }
            return false
        }
        return filteredRequests
    }
}
