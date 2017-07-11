import Foundation

import AFNetworking

public typealias JSONObject = [String: AnyObject]

public enum HTTPMethod {
    case get
}

public protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [AnyHashable: Any] { get }
    associatedtype ResponseType: JSONDecodable
}

public enum APIError: Error {
    case unexpectedResponse
}

open class GitHubAPI {
    fileprivate let HTTPSessionManager: AFHTTPSessionManager = {
        let manager = AFHTTPSessionManager(baseURL: URL(string: "https://api.github.com/"))
        manager.requestSerializer.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        return manager
    }()

    public init() {
    }

    open func request<Endpoint: APIEndpoint>(_ endpoint: Endpoint, handler: @escaping (_ task: URLSessionDataTask, _ response: Endpoint.ResponseType?, _ error: Error?) -> Void) {
        let success = { (task: URLSessionDataTask, response: Any?) -> Void in
            if let JSON = response as? JSONObject {
                do {
                    let response = try Endpoint.ResponseType(JSON: JSON)
                    handler(task, response, nil)
                } catch {
                    handler(task, nil, error)
                }
            } else {
                handler(task, nil, APIError.unexpectedResponse)
            }
        }
        let failure = { (task: URLSessionDataTask?, error: Error) -> Void in
            var newError: NSError = error as NSError
            if let errorData = error._userInfo?[AFNetworkingOperationFailingURLResponseDataErrorKey] as? Data,
                let errorDescription = NSString(data: errorData, encoding: String.Encoding.utf8.rawValue) {
                var userInfo = error._userInfo
                // userInfo?[NSLocalizedFailureReasonErrorKey] = errorDescription
                newError = NSError(domain: error._domain, code: error._code, userInfo: userInfo as! [AnyHashable : Any])
            }
            handler(task!, nil, newError)
        }

        switch endpoint.method {
        case .get:
            HTTPSessionManager.get(endpoint.path, parameters: endpoint.parameters, progress: nil, success: success, failure: failure)
        }
    }

    // MARK: - Endpoints

    public struct SearchRepositories: APIEndpoint {
        public var path = "search/repositories"
        public var method = HTTPMethod.get
        public var parameters: [AnyHashable: Any] {
            return [
                "q" : query,
                "page" : page,
            ]
        }
        public typealias ResponseType = SearchResult<Repository>

        public let query: String
        public let page: Int

        public init(query: String, page: Int) {
            self.query = query
            self.page = page
        }
    }
}

public protocol JSONDecodable {
    init(JSON: JSONObject) throws
}

public enum JSONDecodeError: Error, CustomDebugStringConvertible {
    case missingRequiredKey(String)
    case unexpectedType(key: String, expected: Any.Type, actual: Any.Type)
    case cannotParseURL(key: String, value: String)
    case cannotParseDate(key: String, value: String)

    public var debugDescription: String {
        switch self {
        case .missingRequiredKey(let key):
            return "JSON Decode Error: Required key '\(key)' missing"
        case let .unexpectedType(key: key, expected: expected, actual: actual):
            return "JSON Decode Error: Unexpected type '\(actual)' was supplied for '\(key): \(expected)'"
        case let .cannotParseURL(key: key, value: value):
            return "JSON Decode Error: Cannot parse URL '\(value)' for key '\(key)'"
        case let .cannotParseDate(key: key, value: value):
            return "JSON Decode Error: Cannot parse date '\(value)' for key '\(key)'"
        }
    }
}

public struct SearchResult<ItemType: JSONDecodable>: JSONDecodable {
    public let totalCount: Int
    public let incompleteResults: Bool
    public let items: [ItemType]

    public init(JSON: JSONObject) throws {
        self.totalCount = try getValue(JSON, key: "total_count")
        self.incompleteResults = try getValue(JSON, key: "incomplete_results")
        self.items = try (getValue(JSON, key: "items") as [JSONObject]).mapWithRethrow { return try ItemType(JSON: $0) }
    }
}

public struct Repository: JSONDecodable {
    public let id: Int
    public let name: String
    public let fullName: String
    public let isPrivate: Bool
    public let HTMLURL: Foundation.URL
    public let description: String?
    public let fork: Bool
    public let URL: Foundation.URL
    public let createdAt: Date
    public let updatedAt: Date
    public let pushedAt: Date?
    public let homepage: String?
    public let size: Int
    public let stargazersCount: Int
    public let watchersCount: Int
    public let language: String?
    public let forksCount: Int
    public let openIssuesCount: Int
    public let masterBranch: String?
    public let defaultBranch: String
    public let score: Double
    public let owner: User

    public init(JSON: JSONObject) throws {
        self.id = try getValue(JSON, key: "id")
        self.name = try getValue(JSON, key: "name")
        self.fullName = try getValue(JSON, key: "full_name")
        self.isPrivate = try getValue(JSON, key: "private")
        self.HTMLURL = try getURL(JSON, key: "html_url")
        self.description = try getOptionalValue(JSON, key: "description")
        self.fork = try getValue(JSON, key: "fork")
        self.URL = try getURL(JSON, key: "url")
        self.createdAt = try getDate(JSON, key: "created_at")
        self.updatedAt = try getDate(JSON, key: "updated_at")
        self.pushedAt = try getOptionalDate(JSON, key: "pushed_at")
        self.homepage = try getOptionalValue(JSON, key: "homepage")
        self.size = try getValue(JSON, key: "size")
        self.stargazersCount = try getValue(JSON, key: "stargazers_count")
        self.watchersCount = try getValue(JSON, key: "watchers_count")
        self.language = try getOptionalValue(JSON, key: "language")
        self.forksCount = try getValue(JSON, key: "forks_count")
        self.openIssuesCount = try getValue(JSON, key: "open_issues_count")
        self.masterBranch = try getOptionalValue(JSON, key: "master_branch")
        self.defaultBranch = try getValue(JSON, key: "default_branch")
        self.score = try getValue(JSON, key: "score")
        self.owner = try User(JSON: getValue(JSON, key: "owner") as JSONObject)
    }
}

public struct User: JSONDecodable {
    public let login: String
    public let id: Int
    public let avatarURL: Foundation.URL
    public let gravatarID: String
    public let URL: Foundation.URL
    public let receivedEventsURL: Foundation.URL
    public let type: String

    public init(JSON: JSONObject) throws {
        self.login = try getValue(JSON, key: "login")
        self.id = try getValue(JSON, key: "id")
        self.avatarURL = try getURL(JSON, key: "avatar_url")
        self.gravatarID = try getValue(JSON, key: "gravatar_id")
        self.URL = try getURL(JSON, key: "url")
        self.receivedEventsURL = try getURL(JSON, key: "received_events_url")
        self.type = try getValue(JSON, key: "type")
    }
}

// MARK: - Utilities

private func getURL(_ JSON: JSONObject, key: String) throws -> URL {
    let URLString: String = try getValue(JSON, key: key)
    guard let URL = URL(string: URLString) else {
        throw JSONDecodeError.cannotParseURL(key: key, value: URLString)
    }
    return URL
}

private func getOptionalURL(_ JSON: JSONObject, key: String) throws -> URL? {
    guard let URLString: String = try getOptionalValue(JSON, key: key) else { return nil }
    guard let URL = URL(string: URLString) else {
        throw JSONDecodeError.cannotParseURL(key: key, value: URLString)
    }
    return URL
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    return formatter
}()

private func getDate(_ JSON: JSONObject, key: String) throws -> Date {
    let dateString: String = try getValue(JSON, key: key)
    guard let date = dateFormatter.date(from: dateString) else {
        throw JSONDecodeError.cannotParseDate(key: key, value: dateString)
    }
    return date
}

private func getOptionalDate(_ JSON: JSONObject, key: String) throws -> Date? {
    guard let dateString: String = try getOptionalValue(JSON, key: key) else { return nil }
    guard let date = dateFormatter.date(from: dateString) else {
        throw JSONDecodeError.cannotParseDate(key: key, value: dateString)
    }
    return date
}

private func getValue<T>(_ JSON: JSONObject, key: String) throws -> T {
    guard let value = JSON[key] else {
        throw JSONDecodeError.missingRequiredKey(key)
    }
    guard let typedValue = value as? T else {
        throw JSONDecodeError.unexpectedType(key: key, expected: T.self, actual: type(of: value))
    }
    return typedValue
}

private func getOptionalValue<T>(_ JSON: JSONObject, key: String) throws -> T? {
    guard let value = JSON[key] else {
        return nil
    }
    if value is NSNull {
        return nil
    }
    guard let typedValue = value as? T else {
        throw JSONDecodeError.unexpectedType(key: key, expected: T.self, actual: type(of: value))
    }
    return typedValue
}

private extension Array {
    func mapWithRethrow<T>(_ transform: (Array.Iterator.Element) throws -> T) rethrows -> [T] {
        var mapped: [T] = []
        for element in self {
            mapped.append(try transform(element))
        }
        return mapped
    }
}
