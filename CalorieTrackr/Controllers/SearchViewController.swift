//
//  SearchViewController.swift
//  CalorieTrackr
//
//  Created by Andrei Tatucu on 13.06.2023.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class SearchViewController: UIViewController {
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    
    private var ids : [String] = []
    private var filteredIDs: [String] = []
    
    private var detailViewController: DetailViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchBar()
        setupTableView()
        setupDetailViewController()
        fetchUsers()
    }
    
    private func fetchUsers()
    {
        let dbz = Firestore.firestore()
        let usersCollection = dbz.collection("Users")

        usersCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting users: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                return
            }
            
            for document in documents {
                let name = document.get("Email") as? String ?? ""
                self.ids.append(name)
                print("email: \(name)")
            }
        }
        print("Tatucu")
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search IDs"
        
        view.addSubview(searchBar)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func setupDetailViewController() {
        detailViewController = DetailViewController()
        addChild(detailViewController!)
        view.addSubview(detailViewController!.view)
        detailViewController?.didMove(toParent: self)
        
        detailViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        detailViewController!.view.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        detailViewController!.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        detailViewController!.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        detailViewController!.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        detailViewController!.view.isHidden = true
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredIDs = []
        } else {
            filteredIDs = ids.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
        
        tableView.reloadData()
        detailViewController?.view.isHidden = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredIDs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = filteredIDs[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedID = filteredIDs[indexPath.row]
        
        searchBar.text = selectedID // Autofill the search bar with selected ID
        
        detailViewController?.configureProfile(with: selectedID)
        detailViewController?.view.isHidden = false
    }
}

