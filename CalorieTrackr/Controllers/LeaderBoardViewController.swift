//
//  LeaderBoardViewController.swift
//  CalorieTrackr
//
//  Created by Andrei Tatucu on 09.06.2023.
//

import UIKit

class LeaderBoardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // Sample leaderboard data
    let leaderboardData = [
        ("John", 500),
        ("Emma", 450),
        ("Alex", 400),
        ("Sophia", 350),
        ("Noah", 300)
    ]
    
    // Table view to display leaderboard
    var tableView: UITableView!
    var segmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Create and configure the title label
        let titleLabel = UILabel()
        titleLabel.text = "Today's Leaderboards"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        
        // Create and configure the segmented control
        segmentedControl = UISegmentedControl(items: ["Calories Eaten\nToday", "Calories Burned\nToday", "Streaks"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        view.addSubview(segmentedControl)
        
        // Create and configure the table view
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(LeaderboardCell.self, forCellReuseIdentifier: LeaderboardCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
        
        // Set constraints for the title label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Set constraints for the segmented control
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        // Set constraints for the table view
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    // MARK: - UITableViewDataSource methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaderboardData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LeaderboardCell.identifier, for: indexPath) as! LeaderboardCell
        
        let player = leaderboardData[indexPath.row]
        cell.configure(with: player, position: indexPath.row + 1)
        
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
            // Handle segmented control value change
            let selectedIndex = sender.selectedSegmentIndex
            switch selectedIndex {
            case 0:
                // Friends leaderboard
                // Implement logic to update the leaderboard data accordingly
                break
            case 1:
                // Country leaderboard
                // Implement logic to update the leaderboard data accordingly
                break
            case 2:
                // World leaderboard
                // Implement logic to update the leaderboard data accordingly
                break
            default:
                break
            }
            
            // Reload the table view data after updating the leaderboard data
            tableView.reloadData()
        }
}

class LeaderboardCell: UITableViewCell {
    
    static let identifier = "LeaderboardCell"
    
    let positionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
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
    
    let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(positionLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(scoreLabel)
        
        NSLayoutConstraint.activate([
            positionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            positionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: positionLabel.trailingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            scoreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            scoreLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with player: (name: String, score: Int), position: Int) {
        positionLabel.text = "\(position)."
        nameLabel.text = player.name
        scoreLabel.text = "\(player.score)"
    }
}
