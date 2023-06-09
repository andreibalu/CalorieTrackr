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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Create and configure the table view
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(LeaderboardCell.self, forCellReuseIdentifier: LeaderboardCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
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
