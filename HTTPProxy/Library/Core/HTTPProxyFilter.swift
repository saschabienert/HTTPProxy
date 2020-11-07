import Foundation

public struct KeyValuePair {
    public let key: String
    public let value: String?
    
    public init(_ key: String, _ value: String? = nil) {
        self.key = key
        self.value = value
    }
}

extension KeyValuePair: Equatable {
    public static func == (lhs: KeyValuePair, rhs: KeyValuePair) -> Bool {
        return lhs.key == rhs.key && lhs.value == rhs.value
    }
}

public protocol QuickFilter: AnyObject {
    var name: String { get }
    var enabled: Bool { get set }
    func matchesRequest(_ request: URLRequest) -> Bool
}

public class RequestFilter {
    public var httpMethod: String?
    public var scheme: String?
    public var host: String?
    public var port: Int?
    public var queryItems: [KeyValuePair]?
    public var headerFields: [KeyValuePair]?
    
    public init() {}
}

public class HTTPProxyFilter: QuickFilter {
    public var name: String
    public var enabled = false
    public var requestFilter: RequestFilter

    public init(name: String, requestFilter: RequestFilter) {
        self.name = name
        self.requestFilter = requestFilter
    }
    
    public func matchesRequest(_ request: URLRequest) -> Bool {
        if let method = requestFilter.httpMethod, method != request.httpMethod {
            return false
        }
        
        if let queryItems = requestFilter.headerFields {
            for pair in queryItems {
                guard let items = request.allHTTPHeaderFields else {
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
        
        guard let url = request.url, let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
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

extension HTTPProxyFilter: Equatable {
    public static func == (lhs: HTTPProxyFilter, rhs: HTTPProxyFilter) -> Bool {
        lhs === rhs
    }
}
