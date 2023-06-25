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
        tableView.backgroundColor = .white
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
            columnLabelsStackView.heightAnchor.constraint(equalToConstant: 40)
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

//    func createColumnLabel(title: String) -> UILabel {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.textColor = .gray
//        label.textAlignment = .center
//        label.numberOfLines = 2
//
//        switch segmentedControl.selectedSegmentIndex {
//        case 0:
//            // Display consumed field
//            if title == "Calories Consumed" {
//                label.text = title
//            } else {
//                label.isHidden = true
//            }
//        case 1:
//            // Display activeBurned field
//            if title == "Calories Burned" {
//                label.text = title
//            } else {
//                label.isHidden = true
//            }
//        case 2:
//            // Display streak field
//            if title == "Streak" {
//                label.text = title
//            } else {
//                label.isHidden = true
//            }
//        default:
//            break
//        }
//
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }
    
    func createColumnLabel(title: String) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = title
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }



    @objc func refreshData(_ sender: UIRefreshControl) {
        // Refresh leaderboard data
        fetchFollowingList()
        // End refreshing
        //tableView.reloadData()
        //tableView.reloadData()
        sender.endRefreshing()
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
                let name = document.get("Name") as? String ?? ""
                let streak = document.get("streak") as? Int ?? 0
                let activeBurned = document.get("activeBurned") as? Int ?? 0
                let consumed = document.get("consumed") as? Int ?? 0
                userData[id] = UserData(name: name, streak: streak, activeBurned: activeBurned, consumed: consumed)
                print("ID: \(id), Name: \(name), Streak: \(streak), Active Burned: \(activeBurned), Consumed: \(consumed)")
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
        let name = data?.name ?? ""
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            cell.consumedLabel.text = "\(data?.consumed ?? 0)"
            cell.burnedLabel.isHidden = true
            cell.streakLabel.isHidden = true
        case 1:
            cell.burnedLabel.text = "\(data?.activeBurned ?? 0)"
            cell.consumedLabel.isHidden = true
            cell.streakLabel.isHidden = true
        case 2:
            cell.streakLabel.text = "\(data?.streak ?? 0)"
            cell.consumedLabel.isHidden = true
            cell.burnedLabel.isHidden = true
        default:
            break
        }
        
        cell.configure(with: rank, name: name, segmentedControl:segmentedControl)
        
        if id == Auth.auth().currentUser?.email {
            cell.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.2)
        } else {
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
            leaderboardData.sort { id1, id2 in
                let consumed1 = userData[id1]?.consumed ?? 0
                let consumed2 = userData[id2]?.consumed ?? 0
                return consumed1 > consumed2
            }
            let consumedNames = leaderboardData.prefix(3).map { userData[$0]?.name ?? "" }
            UserDefaults.standard.set(consumedNames[0], forKey: "consumed1")
            UserDefaults.standard.set(consumedNames[1], forKey: "consumed2")
            UserDefaults.standard.set(consumedNames[2], forKey: "consumed3")
        case 1:
            leaderboardData.sort { id1, id2 in
                let burned1 = userData[id1]?.activeBurned ?? 0
                let burned2 = userData[id2]?.activeBurned ?? 0
                return burned1 > burned2
            }
            let burnedNames = leaderboardData.prefix(3).map { userData[$0]?.name ?? "" }
            UserDefaults.standard.set(burnedNames[0], forKey: "burned1")
            UserDefaults.standard.set(burnedNames[1], forKey: "burned2")
            UserDefaults.standard.set(burnedNames[2], forKey: "burned3")
        case 2:
            leaderboardData.sort { id1, id2 in
                let streak1 = userData[id1]?.streak ?? 0
                let streak2 = userData[id2]?.streak ?? 0
                return streak1 > streak2
            }
            let streakNames = leaderboardData.prefix(3).map { userData[$0]?.name ?? "" }
            UserDefaults.standard.set(streakNames[0], forKey: "streak1")
            UserDefaults.standard.set(streakNames[1], forKey: "streak2")
            UserDefaults.standard.set(streakNames[2], forKey: "streak3")
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
    
    let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            let borderWidth: CGFloat = 0.0
            let borderColor = UIColor.lightGray.cgColor
            
            contentView.addSubview(rankLabel)
            contentView.addSubview(nameLabel)
            contentView.addSubview(scoreLabel)
            
            // Add outlines to each column
            rankLabel.layer.borderWidth = borderWidth
            rankLabel.layer.borderColor = borderColor
            nameLabel.layer.borderWidth = borderWidth
            nameLabel.layer.borderColor = borderColor
            scoreLabel.layer.borderWidth = borderWidth
            scoreLabel.layer.borderColor = borderColor
            
            // Center-align the rank label and score label
            rankLabel.textAlignment = .center
            scoreLabel.textAlignment = .center
            
            NSLayoutConstraint.activate([
                rankLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                rankLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                rankLabel.widthAnchor.constraint(equalToConstant: 50), // Adjust width as needed
                
                nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                nameLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor),
                nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                
                scoreLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                scoreLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
                scoreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                scoreLabel.widthAnchor.constraint(equalToConstant: 80) // Adjust width as needed
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
//            consumedLabel.isHidden = false
//            burnedLabel.isHidden = true
//            streakLabel.isHidden = true
            scoreLabel.text = consumedLabel.text
        case 1:
//            consumedLabel.isHidden = true
//            burnedLabel.isHidden = false
//            streakLabel.isHidden = true
            scoreLabel.text = burnedLabel.text
        case 2:
//            consumedLabel.isHidden = true
//            burnedLabel.isHidden = true
//            streakLabel.isHidden = false
            scoreLabel.text = streakLabel.text
        default:
            break
        }
    }
}


struct UserData {
    let name: String
    let streak: Int
    let activeBurned: Int
    let consumed: Int
}


