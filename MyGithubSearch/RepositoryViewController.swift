import UIKit

import SafariServices

class RepositoryViewController: UIViewController, ApplicationContextSettable {
    var appContext: ApplicationContext!
    var repository: Repository!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = repository.name
    }
}