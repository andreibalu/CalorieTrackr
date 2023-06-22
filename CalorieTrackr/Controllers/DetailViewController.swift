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
    
    let streakLabel = UILabel()
    let heightLabel = UILabel()
    let weightLabel = UILabel()
    let sexLabel = UILabel()
    let targetLabel = UILabel()
    let rankLabel = UILabel()
    
    //Displayed User Data
    var name: String = ""
    var streak: Int = 0
    var height: String = ""
    var weight: String = ""
    var sex: String = ""
    var target: String = ""
    var followingCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        if let navyColor = UIColor(named: "ColorNavy") {
            view.backgroundColor = navyColor
        }
        else
        {
            view.backgroundColor = .black
        }
        
        streakLabel.textColor = .white
        streakLabel.font = UIFont.boldSystemFont(ofSize: 23)
        heightLabel.textColor = .white
        heightLabel.font = UIFont.boldSystemFont(ofSize: 23)
        weightLabel.textColor = .white
        weightLabel.font = UIFont.boldSystemFont(ofSize: 23)
        sexLabel.textColor = .white
        sexLabel.font = UIFont.boldSystemFont(ofSize: 23)
        targetLabel.textColor = .white
        targetLabel.font = UIFont.boldSystemFont(ofSize: 23)
        rankLabel.textColor = .white
        rankLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.textColor = .white
        titleLabel.textColor = .white
        
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
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupProfileImageView() {
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.layer.cornerRadius = 100
        profileImageView.layer.masksToBounds = true
        
        view.addSubview(profileImageView)
    }
    
    private func setupNameLabel() {
        nameLabel.font = UIFont.boldSystemFont(ofSize: 30)
        nameLabel.textAlignment = .center
        
        view.addSubview(nameLabel)
    }
    
    private func setupTitleLabel() {
        titleLabel.font = UIFont.systemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        
        view.addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        followButton.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .center // Center the labels within the stack view
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add labels to the stack view
        stackView.addArrangedSubview(streakLabel)
        stackView.addArrangedSubview(rankLabel)
        stackView.addArrangedSubview(heightLabel)
        stackView.addArrangedSubview(weightLabel)
        stackView.addArrangedSubview(sexLabel)
        stackView.addArrangedSubview(targetLabel)
        
        // Add stack view to the main view
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            stackView.topAnchor.constraint(equalTo: followButton.bottomAnchor, constant: 70),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    
    public func configureProfile(with userId: String) {
        titleLabel.text = id
        self.id = userId
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
                let following = document.get("following") as? [String] ?? []
                
                self.nameLabel.text = name
                self.titleLabel.text = userId
                
                self.streakLabel.text = "Streak: \(streak)"
                self.heightLabel.text = "Height: \(height)"
                self.weightLabel.text = "Weight: \(weight)"
                self.sexLabel.text = "Sex: \(sex)"
                self.targetLabel.text = "Target: \(target)"
                
                if (streak < 5)
                {
                    self.rankLabel.text = "Wonderer"
                }
                else if (streak >= 5 && streak < 20)
                {
                    self.rankLabel.text = "Fighter"
                }
                else if (streak >= 20 && streak < 40)
                {
                    self.rankLabel.text = "Warrior"
                }
                else if (streak >= 40 && streak < 80)
                {
                    self.rankLabel.text = "Captain"
                }
                else if (streak >= 80 && streak < 130)
                {
                    self.rankLabel.text = "General"
                }
                else if (streak >= 130)
                {
                    self.rankLabel.text = "Special Agent"
                }
                
                if let currentUser = Auth.auth().currentUser?.email{
                    print(currentUser as Any)
                    let userDocumentRef = db.collection(K.FStore.collectionName).document(currentUser)
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        userDocumentRef.getDocument { (document, error) in
                            if let document = document, document.exists {
                                if let followingValue = document.data()?["following"] as? [String],
                                    let currentId = document.data()?["Email"] as? String
                                {
                                    if (userId == currentId)
                                    {
                                        self.followButton.setTitle("Viewing As Guest", for: .normal)
                                        self.followButton.backgroundColor = .purple
                                        self.followButton.isEnabled = false
                                    }
                                    else if (followingValue.contains(userId))
                                    {
                                        self.followButton.setTitle("Following", for: .normal)
                                        self.followButton.backgroundColor = .purple
                                        self.followButton.isEnabled = true
                                    }
                                    else
                                    {
                                        self.followButton.setTitle("Follow", for: .normal)
                                        self.followButton.backgroundColor = .blue
                                        self.followButton.isEnabled = true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func setupFollowButton(selectedID: String?) {
        followButton.setTitleColor(.white, for: .normal)
        followButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        followButton.layer.cornerRadius = 10
        followButton.clipsToBounds = true
        
        followButton.addTarget(self, action: #selector(followButtonTapped(_:)), for: .touchUpInside)
        
        view.addSubview(followButton)

        followButton.translatesAutoresizingMaskIntoConstraints = false
        followButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 70).isActive = true
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
                                let alert = UIAlertController(title: "Unfollow User", message: "Would you like to unfollow this user?", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                                alert.addAction(UIAlertAction(title: "Unfollow", style: .default, handler: { (_) in
                                    followingValue.removeAll { $0 == self.id }
                                    userDocumentRef.updateData(["following": followingValue]) { error in
                                    if let error = error {
                                        print("Error updating following array in the database: \(error.localizedDescription)")
                                    }
                                    else {
                                        self.followButton.setTitle("Follow", for: .normal)
                                        self.followButton.backgroundColor = .blue
                                        print("Successfully updated following array in the database")
                                        }
                                    }
                                }))
                                self.present(alert, animated: true, completion: nil)
                                
                            }
                            else {
                                followingValue.append(self.id)

                                userDocumentRef.updateData(["following": followingValue]) { error in
                                if let error = error {
                                    print("Error updating following array in the database: \(error.localizedDescription)")
                                }
                                else {
                                    self.followButton.setTitle("Following", for: .normal)
                                    self.followButton.backgroundColor = .purple
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

