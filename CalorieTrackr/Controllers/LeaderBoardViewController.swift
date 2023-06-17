import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class LeaderBoardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let db = Firestore.firestore()
    var leaderboardData: [String] = []
    var userData: [String: UserData] = [:]

    // Table view to display leaderboard
    var tableView: UITableView!
    var segmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        let titleLabel = UILabel()
        titleLabel.text = "Today's Leaderboards"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)

        segmentedControl = UISegmentedControl(items: ["Calories Eaten\nToday", "Calories Burned\nToday", "Streaks"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        view.addSubview(segmentedControl)

        let columnLabelsStackView = UIStackView()
        columnLabelsStackView.axis = .horizontal
        columnLabelsStackView.distribution = .fillEqually

        let rankLabel = createColumnLabel(title: "")
        let nameLabel = createColumnLabel(title: "")
        let consumedLabel = createColumnLabel(title: "")
        let burnedLabel = createColumnLabel(title: "")
        let streakLabel = createColumnLabel(title: "")

        columnLabelsStackView.addArrangedSubview(rankLabel)
        columnLabelsStackView.addArrangedSubview(nameLabel)
        columnLabelsStackView.addArrangedSubview(consumedLabel)
        columnLabelsStackView.addArrangedSubview(burnedLabel)
        columnLabelsStackView.addArrangedSubview(streakLabel)

        view.addSubview(columnLabelsStackView)

        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(LeaderboardCell.self, forCellReuseIdentifier: LeaderboardCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        view.addSubview(tableView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        columnLabelsStackView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    columnLabelsStackView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
                    columnLabelsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                    columnLabelsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                    columnLabelsStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0/4.0)
                ])

        tableView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    tableView.topAnchor.constraint(equalTo: columnLabelsStackView.bottomAnchor, constant: 8),
                    tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor) // Align horizontally to center
                ])

        fetchFollowingList()

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.reloadData()
    }

    func createColumnLabel(title: String) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 2
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            // Display consumed field
            if title == "Calories Consumed" {
                label.text = title
            } else {
                label.isHidden = true
            }
        case 1:
            // Display activeBurned field
            if title == "Calories Burned" {
                label.text = title
            } else {
                label.isHidden = true
            }
        case 2:
            // Display streak field
            if title == "Streak" {
                label.text = title
            } else {
                label.isHidden = true
            }
        default:
            break
        }
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }



    @objc func refreshData(_ sender: UIRefreshControl) {
        // Refresh leaderboard data
        fetchFollowingList()
        // End refreshing
        tableView.reloadData()
        tableView.reloadData()
        sender.endRefreshing()
        tableView.reloadData()
        tableView.reloadData()
    }

    private func fetchFollowingList() {
        if let currentUser = Auth.auth().currentUser?.email {
            print(currentUser as Any)
            let userDocumentRef = db.collection(K.FStore.collectionName).document(currentUser)
            DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                userDocumentRef.getDocument { (document, error) in
                    guard let self = self else { return }
                    if let document = document, document.exists {
                        if let followingValue = document.data()?["following"] as? [String] {
                            self.leaderboardData = followingValue
                            // Add the current user to the leaderboard data
                            if !self.leaderboardData.contains(currentUser) {
                                self.leaderboardData.append(currentUser)
                            }
                            self.fetchUsers()
                            self.tableView.reloadData()
                        } else {
                            print("Error retrieving data from the database: \(String(describing: error?.localizedDescription))")
                        }
                    }
                }
            }
        }
    }

    private func fetchUsers() {
        let usersCollection = db.collection("Users")
        let query = usersCollection.whereField("Email", in: leaderboardData)
        query.getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error getting users: \(error)")
                return
            }
            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                return
            }
            var userData: [String: UserData] = [:]
            for document in documents {
                let id = document.documentID
                let streak = document.get("streak") as? Int ?? 0
                let activeBurned = document.get("activeBurned") as? Int ?? 0
                let consumed = document.get("consumed") as? Int ?? 0
                userData[id] = UserData(streak: streak, activeBurned: activeBurned, consumed: consumed)
                print("ID: \(id), Streak: \(streak), Active Burned: \(activeBurned), Consumed: \(consumed)")
            }
            self.userData = userData
            // Sort the leaderboard data based on the selected tab
            self.segmentedControlValueChanged(self.segmentedControl)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaderboardData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LeaderboardCell.identifier, for: indexPath) as! LeaderboardCell
        
        let rank = indexPath.row + 1
        let id = leaderboardData[indexPath.row]
        let data = userData[id]
        
        cell.configure(with: rank, name: id, segmentedControl:segmentedControl)
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            // Display consumed field
            cell.consumedLabel.text = "\(data?.consumed ?? 0)"
            cell.burnedLabel.isHidden = true
            cell.streakLabel.isHidden = true
        case 1:
            // Display activeBurned field
            cell.burnedLabel.text = "\(data?.activeBurned ?? 0)"
            cell.consumedLabel.isHidden = true
            cell.streakLabel.isHidden = true
        case 2:
            // Display streak field
            cell.streakLabel.text = "\(data?.streak ?? 0)"
            cell.consumedLabel.isHidden = true
            cell.burnedLabel.isHidden = true
        default:
            break
        }
        
        if id == Auth.auth().currentUser?.email {
            // Set the background color for the current user cell
            cell.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.2)
        } else {
            // Set the default background color for other cells
            cell.backgroundColor = .clear
        }
        
        return cell
    }


    // MARK: - UITableViewDelegate methods

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle row selection if needed
    }

    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        switch selectedIndex {
        case 0:
            // Sort by consumed
            leaderboardData.sort { id1, id2 in
                let consumed1 = userData[id1]?.consumed ?? 0
                let consumed2 = userData[id2]?.consumed ?? 0
                return consumed1 > consumed2
            }
        case 1:
            // Sort by activeBurned
            leaderboardData.sort { id1, id2 in
                let burned1 = userData[id1]?.activeBurned ?? 0
                let burned2 = userData[id2]?.activeBurned ?? 0
                return burned1 > burned2
            }
        case 2:
            // Sort by streaks
            leaderboardData.sort { id1, id2 in
                let streak1 = userData[id1]?.streak ?? 0
                let streak2 = userData[id2]?.streak ?? 0
                return streak1 > streak2
            }
        default:
            break
        }

        tableView.reloadData()
        tableView.reloadData()
        tableView.reloadData()
    }

}

class LeaderboardCell: UITableViewCell {
    static let identifier = "LeaderboardCell"

    let rankLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let consumedLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let burnedLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let streakLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(rankLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(consumedLabel)
        contentView.addSubview(burnedLabel)
        contentView.addSubview(streakLabel)
        NSLayoutConstraint.activate([
            rankLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rankLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            rankLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1/5),

            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor),
            nameLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1/5),

            consumedLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            consumedLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            consumedLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1/5),

            burnedLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            burnedLabel.leadingAnchor.constraint(equalTo: consumedLabel.trailingAnchor),
            burnedLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1/5),

            streakLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            streakLabel.leadingAnchor.constraint(equalTo: burnedLabel.trailingAnchor),
            streakLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            streakLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1/5)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with rank: Int, name: String, segmentedControl: UISegmentedControl) {
        rankLabel.text = "\(rank)"
        nameLabel.text = name
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            consumedLabel.isHidden = false
            burnedLabel.isHidden = true
            streakLabel.isHidden = true
        case 1:
            consumedLabel.isHidden = true
            burnedLabel.isHidden = false
            streakLabel.isHidden = true
        case 2:
            consumedLabel.isHidden = true
            burnedLabel.isHidden = true
            streakLabel.isHidden = false
        default:
            break
        }
    }
}


struct UserData {
    let streak: Int
    let activeBurned: Int
    let consumed: Int
}


