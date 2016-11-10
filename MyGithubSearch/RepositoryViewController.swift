import UIKit

import SafariServices

class RepositoryViewController: UIViewController, ApplicationContextSettable {
    var appContext: ApplicationContext!
    var repository: Repository!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var URLButton: UIButton!


    override func viewDidLoad() {
        super.viewDidLoad()
        title = repository.name
        nameLabel.text = repository.fullName
        URLButton.setTitle(repository.HTMLURL.absoluteString, for: UIControlState())
    }

    @IBAction func openURL(_ sender: AnyObject) {
        let safari = SFSafariViewController(url: repository.HTMLURL as URL)
        safari.delegate = self
        present(safari, animated: true, completion: nil)
    }
}

extension RepositoryViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
