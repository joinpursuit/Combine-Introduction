import UIKit
import Combine

class RandomUsersViewController: UIViewController {

    @IBOutlet var randomUsersTableView: UITableView!
    
    private var randomUsersSubription: AnyCancellable?
    
    var users = [User]() {
        didSet {
            randomUsersTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        randomUsersTableView.delegate = self
        randomUsersTableView.dataSource = self
        loadUsers()
    }
    
    private func loadUsers() {
        RandomUserAPIClient.getRandomUsers { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case let .success(users):
                    self?.users = users
                case let .failure(error):
                    print(error)
                }
            }
        }
        let publisher = RandomUserAPIClient.randomUsersPublisher()
        randomUsersSubription = publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] (completion) in
                switch completion {
                case .finished: break
                case let .failure(error):
                    print(error)
                }
            }, receiveValue: { [weak self] (users) in
                self?.users = users
            })
    }
}

extension RandomUsersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        let user = users[indexPath.row]
        cell.textLabel?.text = "\(user.name.first) \(user.name.last)"
        cell.detailTextLabel?.text = user.email
        return cell
    }
}

