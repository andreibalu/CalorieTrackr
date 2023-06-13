//
//  DetailViewController.swift
//  CalorieTrackr
//
//  Created by Andrei Tatucu on 13.06.2023.
//

import UIKit

class DetailViewController: UIViewController {
    var selectedID: String?
    
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let titleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupProfileImageView()
        setupNameLabel()
        setupTitleLabel()
        setupConstraints()
        
        if let selectedID = selectedID {
            configureProfile(with: selectedID)
        }
    }
    
    private func setupProfileImageView() {
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.layer.cornerRadius = 100
        profileImageView.layer.masksToBounds = true
        
        view.addSubview(profileImageView)
    }
    
    private func setupNameLabel() {
        nameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        nameLabel.textAlignment = .center
        
        view.addSubview(nameLabel)
    }
    
    private func setupTitleLabel() {
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        
        view.addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            profileImageView.widthAnchor.constraint(equalToConstant: 200),
            profileImageView.heightAnchor.constraint(equalToConstant: 200),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    public func configureProfile(with id: String) {
        // Assuming you have some data associated with the ID to populate the profile
        let profileData = ProfileData(name: "John Doe", title: "Software Engineer", profileImage: UIImage(named: "profile_image"))
        
        nameLabel.text = profileData.name
        //titleLabel.text = profileData.title
        titleLabel.text = id
        profileImageView.image = profileData.profileImage
    }
}

// Example struct to hold profile data
struct ProfileData {
    let name: String
    let title: String
    let profileImage: UIImage?
}


