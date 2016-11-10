import Foundation

class SearchRepositoriesManager {

    let github: GitHubAPI
    let query: String

    var networking: Bool = false

    var results: [Repository] = []
    var completed: Bool = false
    var page: Int = 1

    init?(github: GitHubAPI, query: String) {
        self.github = github
        self.query = query
        if query.characters.isEmpty {
            return nil
        }
    }

    func search(_ reload: Bool, completion: @escaping (_ error: Error?) -> Void) -> Bool {
        if completed || networking {
            return false
        }
        networking = true
        github.request(GitHubAPI.SearchRepositories(query: query, page: reload ? 1 : page)) { (task, response, error) -> Void in
            if let response = response {
                if reload {
                    self.results.removeAll()
                    self.page = 1
                }
                self.results.append(contentsOf: response.items)
                self.completed = response.totalCount <= self.results.count
                self.page += 1
            }
            completion(error: error)
        }
        return true
    }

}
