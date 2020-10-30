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

public class RequestFilter {
    public var httpMethod: String?
    public var scheme: String?
    public var host: String?
    public var port: Int?
    public var queryItems: [KeyValuePair]?
    public var headerFields: [KeyValuePair]?
}

public class HTTPProxyFilter {
    public var name: String
    public var enabled = false
    public var requestFilter: RequestFilter

    public init(name: String, requestFilter: RequestFilter) {
        self.name = name
        self.requestFilter = requestFilter
    }
}

extension HTTPProxyFilter: Equatable {
    public static func == (lhs: HTTPProxyFilter, rhs: HTTPProxyFilter) -> Bool {
        lhs === rhs
    }
}
