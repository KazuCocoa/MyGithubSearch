import Foundation

class ApplicationContext {
    let github: GitHubAPI = GitHubAPI()
}

protocol ApplicationContextSettable: class {
    var appContext: ApplicationContext! { get set }
}