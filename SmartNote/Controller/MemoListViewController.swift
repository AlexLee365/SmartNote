//
//  MemoListViewController.swift
//  SmartNote
//
//  Created by Solji Kim on 26/06/2019.
//  Copyright © 2019 Alex Lee. All rights reserved.
//

import UIKit

class MemoListViewController: UIViewController {
    
    let titleImageView = UIImageView(image: UIImage(named: "smartmemo"))
    let searchController = UISearchController(searchResultsController: nil)
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setAutoLayout()
    }
    
    // shows search bar without scrolling up
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    // hides search bar when scrolling down
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    
    // MARK: - configuration
    
    private func configure() {
        navigationItem.titleView = titleImageView
        titleImageView.contentMode = .scaleAspectFit
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        searchController.searchBar.placeholder = "검색"
        searchController.obscuresBackgroundDuringPresentation = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MemoListCell.self, forCellReuseIdentifier: "MemoListCell")
        tableView.rowHeight = 80
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
    }
    
    // MARK: - auto layout
    
    private func setAutoLayout() {
        let guide = view.safeAreaLayoutGuide
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}


// MARK: - UITableViewDataSource

extension MemoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemoListCell", for: indexPath) as! MemoListCell
        
        cell.titleLabel.text = "여행이좋아"
        cell.dateLabel.text = "2019. 6. 1."
        cell.descriptionLabel.text = "여행을 통해 누군가의 성장을 바라보며 어ㅓ어어어어어엉어"
        cell.noteIcon.image = UIImage(named: "noteIcon")
        cell.selectionStyle = .none
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MemoListViewController: UITableViewDelegate {
    
}

// MARK: - UISearchResultsUpdating

extension MemoListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

// MARK: - UISearchBarDelegate

extension MemoListViewController: UISearchBarDelegate {
    
}
