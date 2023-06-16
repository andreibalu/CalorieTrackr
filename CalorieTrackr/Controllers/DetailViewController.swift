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
    public var id: String = ""
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let titleLabel = UILabel()
    private let followButton = UIButton(type: .system)
    
    //Displayed User Data
    var name: String = ""
    var streak: Int = 0
    var height: String = ""
    var weight: String = ""
    var sex: String = ""
    var target: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupProfileImageView()
        setupNameLabel()
        setupTitleLabel()
        setupFollowButton(selectedID: selectedID)
        setupConstraints()
        
        if let selectedID = selectedID {
            self.id = selectedID
            configureProfile(with: selectedID)
            setupFollowButton(selectedID: selectedID)
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
        titleLabel.text = id
        self.id = id
        print("Displaying user with id: \(self.id)")
        let db = Firestore.firestore()
        let usersCollection = db.collection("Users")
        let query = usersCollection.whereField("Email", isEqualTo: id)

        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting users: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                return
            }
            print(documents)
            
            for document in documents {
                let name = document.get("Name") as? String ?? ""
                let streak = document.get("streak") as? Int ?? 0
                let height = document.get("Height") as? String ?? ""
                let weight = document.get("Weight") as? String ?? ""
                let sex = document.get("Sex") as? String ?? ""
                let target = document.get("Target") as? String ?? ""
                self.name = name
                self.streak = streak
                self.height = height
                self.weight = weight
                self.sex = sex
                self.target = target
                
                self.nameLabel.text = self.name
            }
        }
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
        
        if (self.id == "")
        {
            return
        }
        
        let db = Firestore.firestore()
        
        if let currentUser = Auth.auth().currentUser?.email{
            print(currentUser as Any)
            let userDocumentRef = db.collection(K.FStore.collectionName).document(currentUser)
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                userDocumentRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        if var followingValue = document.data()?["following"] as? [String] {
                            if(followingValue.contains(self.id)){
                                print("User is already followed")
                            }
                            else {
                                followingValue.append(self.id)

                                userDocumentRef.updateData(["following": followingValue]) { error in
                                if let error = error {
                                    print("Error updating following array in the database: \(error.localizedDescription)")
                                }
                                else {
                                    print("Successfully updated following array in the database")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ProfileData {
    let name: String
    let title: String
    let profileImage: UIImage?
}

