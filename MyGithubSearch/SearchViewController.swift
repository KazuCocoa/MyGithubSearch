import UIKit
import SafariServices

class SearchViewController: UITableViewController, ApplicationContextSettable {

    var appContext: ApplicationContext!

    lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.delegate = self
        controller.searchBar.delegate = self
        return controller
    }()

    var searchManager: SearchRepositoriesManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableHeaderView = searchController.searchBar
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let repositoryVC as RepositoryViewController:
            repositoryVC.appContext = appContext
            if let indexPath = tableView.indexPathForSelectedRow,
                let repository = searchManager?.results[indexPath.row] {
                repositoryVC.repository = repository
            }
        default:
            fatalError("Unexpected segue")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchManager?.results.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryCell", for: indexPath)

        let repository = searchManager!.results[indexPath.row]
        cell.textLabel?.text = repository.fullName
        cell.detailTextLabel?.text = repository.description

        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let searchManager = searchManager, indexPath.row >= searchManager.results.count - 1 {
            searchManager.search(false) { [weak self] (error) in
                if let error = error {
                    print(error)
                } else {
                    self?.tableView.reloadData()
                }
            }
        }
    }
}


extension SearchViewController: UISearchControllerDelegate {
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let searchText = searchController.searchBar.text else { return }
        guard let searchManager = SearchRepositoriesManager(github: appContext.github, query: searchText) else { return }
        self.searchManager = searchManager
        searchManager.search(true) { [weak self] (error) in
            if let error = error {
                print(error)
            } else {
                self?.tableView.reloadData()
                self?.searchController.isActive = false
            }
        }
    }
}
