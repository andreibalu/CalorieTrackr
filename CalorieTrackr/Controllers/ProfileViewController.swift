//
//  ProfileViewController.swift
//  CalorieTrackr
//
//  Created by Andrei Tatucu on 09.06.2023.
//

import UIKit

class ProfileViewController: UIViewController {
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "profile_image"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.borderWidth = 2.0
        imageView.layer.borderColor = UIColor.red.cgColor
        imageView.layer.cornerRadius = 60.0
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.text = "John Doe"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "Software Engineer"
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let aboutLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "About Me"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let aboutTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.text = "I am a software engineer with a passion for coding and building great apps. I have experience in iOS development and enjoy exploring new technologies."
        textView.textColor = .darkGray
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // Add subviews
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(infoLabel)
        view.addSubview(aboutLabel)
        view.addSubview(aboutTextView)
        
        // Configure layout constraints
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            infoLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            aboutLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 20),
            aboutLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            aboutTextView.topAnchor.constraint(equalTo: aboutLabel.bottomAnchor, constant: 8),
            aboutTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            aboutTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            aboutTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }
}
