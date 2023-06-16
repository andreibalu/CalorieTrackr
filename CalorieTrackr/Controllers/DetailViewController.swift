//
//  DetailViewController.swift
//  CalorieTrackr
//
//  Created by Andrei Tatucu on 13.06.2023.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class DetailViewController: UIViewController {
    var selectedID: String?
    public var id: String?
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let titleLabel = UILabel()
    private let followButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupProfileImageView()
        setupNameLabel()
        setupTitleLabel()
        setupProfileInfoStack()
        setupFollowButton(selectedID: selectedID)
        setupConstraints()
        
        if let selectedID = selectedID {
                id = selectedID
                configureProfile(with: selectedID)
                setupFollowButton(selectedID: selectedID) // Pass the selectedID parameter explicitly
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
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        followButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
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
    
    private func setupProfileInfoStack() {
//        let followingLabel = UILabel()
//        followingLabel.text = "20 following"
//        followingLabel.textColor = .black
//        followingLabel.textAlignment = .center
//
//        let followersLabel = UILabel()
//        followersLabel.text = "20 followers"
//        followersLabel.textColor = .black
//        followersLabel.textAlignment = .center
//
//        let stackView = UIStackView(arrangedSubviews: [followingLabel, followersLabel])
//        stackView.axis = .horizontal
//        stackView.spacing = 20
//
//        view.addSubview(stackView)
//
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
    }
    
    private func setupFollowButton(selectedID: String?) {
        followButton.setTitle("Follow", for: .normal)
        followButton.setTitleColor(.white, for: .normal)
        followButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        followButton.backgroundColor = .purple
        followButton.layer.cornerRadius = 10
        followButton.clipsToBounds = true
        
        followButton.addTarget(self, action: #selector(followButtonTapped(_:)), for: .touchUpInside)
        
        view.addSubview(followButton)

        followButton.translatesAutoresizingMaskIntoConstraints = false
        followButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        followButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        followButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        followButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    
    @objc private func followButtonTapped(_ sender: UIButton) {
        print("Follow tapped")
        
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("No current user")
            return
        }
        
        guard let selectedID = selectedID else {
            print("No selected ID")
            return
        }
        
        let db = Firestore.firestore()
        let currentUserRef = db.collection("Users").document(currentUserID)
        
        currentUserRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching current user document: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                var followingArray = document.data()?["following"] as? [String] ?? []
                
                if followingArray.contains(selectedID) {
                    // If the selected ID already exists in the "following" array, update the button's title and disable interaction
                    self.followButton.setTitle("Following", for: .normal)
                    self.followButton.isEnabled = false
                    print("Already following")
                } else {
                    // Append the selected ID if it doesn't already exist in the array
                    followingArray.append(selectedID)
                    
                    currentUserRef.updateData(["following": followingArray]) { error in
                        if let error = error {
                            print("Error updating following array in the database: \(error.localizedDescription)")
                        } else {
                            print("Successfully updated following array in the database")
                            self.followButton.setTitle("Following", for: .normal)
                            self.followButton.isEnabled = false
                        }
                    }
                }
            }
        }
    }

   

}

// Example struct to hold profile data
struct ProfileData {
    let name: String
    let title: String
    let profileImage: UIImage?
}

