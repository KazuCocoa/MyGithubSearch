import Foundation

class SearchRepositoriesManager {
    let github: GitHubAPI
    let query: String

    var results: [Repository] = []

    init?(github: GitHubAPI, query: String) {
        self.github = github
        self.query = query
        if query.characters.isEmpty {
            return nil
        }
    }

    func search(completion: (error: ErrorType?) -> Void) {
        github.request(GitHubAPI.SearchRepositories(query: query)) { (task, response, error) -> Void in
            if let response = response {
                self.results.appendContentsOf(response.items)
            }
            completion(error: error)
        }
    }
}