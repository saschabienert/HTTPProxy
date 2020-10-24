import Foundation

struct RequestListFilter {
    
    func filterRequests(_ requests: [HTTPRequest], with filters: [HTTPProxyFilter]) -> [HTTPRequest] {
        let enabledFilters = filters.filter({ filter -> Bool in
            filter.enabled
        })
        
        if enabledFilters.count == 0 {
            return requests
        }
        
        let filteredRequests = requests.filter { (request) -> Bool in
            for filter in enabledFilters {
                if shouldIncludeRequest(request, requestFilter: filter.requestFilter) {
                    return true
                }
            }
            return false
        }
        return filteredRequests
    }
    
    private func shouldIncludeRequest(_ request: HTTPRequest, requestFilter: RequestFilter) -> Bool {
        
        if let method = requestFilter.httpMethod, method != request.request.httpMethod {
            return false
        }
        
        if let queryItems = requestFilter.headerFields {
            for pair in queryItems {
                guard let items = request.request.allHTTPHeaderFields else {
                    return false
                }
                var matched = false
                for item in items {
                    if pair.key == item.key && pair.value ?? item.value == item.value {
                        matched = true
                        break
                    }
                }
                if !matched {
                    return false
                }
            }
        }
        
        guard let url = request.request.url, let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false
        }
        
        return shouldIncludeRequest(components, requestFilter: requestFilter)
    }
    
    private func shouldIncludeRequest(_ components: URLComponents, requestFilter: RequestFilter) -> Bool {
        
        if let scheme = requestFilter.scheme, scheme != components.scheme {
            return false
        }
        
        if let host = requestFilter.host, host != components.host {
           return false
        }
        
        if let host = requestFilter.port, host != components.port {
            return false
        }
        
        if let queryItems = requestFilter.queryItems {
            for pair in queryItems {
                guard let items = components.queryItems else {
                    return false
                }
                var matched = false
                for item in items {
                    if pair.key == item.name && pair.value ?? item.value == item.value {
                        matched = true
                        break
                    }
                }
                if !matched {
                    return false
                }
            }
        }
        
        return true
    }
}
