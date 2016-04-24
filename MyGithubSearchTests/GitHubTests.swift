import XCTest
@testable import MyGithubSearch

class MyGithubSearchTests: XCTestCase {

    var github: GitHubAPI!

    override func setUp() {
        super.setUp()
        github = GitHubAPI()
    }
    
    func testSearchRepository() {
        let e = expectationWithDescription("API Request")
        github.request(GitHubAPI.SearchRepositories(query: "Swift")) { (task, response, error) -> Void in
            XCTAssert(response != nil)
            XCTAssert(error == nil)
            e.fulfill()
        }
        waitForExpectationsWithTimeout(10, handler: nil)
    }
}
