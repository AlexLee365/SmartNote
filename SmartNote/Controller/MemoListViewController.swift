//
//  MemoListViewController.swift
//  SmartNote
//
//  Created by 행복한 개발자 on 26/06/2019.
//  Copyright © 2019 Alex Lee. All rights reserved.
//
import UIKit

class MemoListViewController: UIViewController {
    
    let titleImageView = UIImageView(image: UIImage(named: "smartmemo"))
    let searchController = UISearchController(searchResultsController: nil)
    let tableView = UITableView()
    
    var memoArray = [MemoData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setAutoLayout()
        makeData()
    }
    
    func makeData() {
        let date = Date()
        memoArray = [
            MemoData(date: date, text: "청와대는 영변 핵시설 전면 폐기가 북한 비핵화의 되돌릴 수 없는 단계라는 문재인 대통령의 어제 언급과 관련해 영변 핵폐기는 비핵화로 가기 위한 되돌릴 수 없는 단계로 접어드는 입구라고 설명했습니다. \n 청와대 핵심관계자는 오늘 기자들과 만나 어떤 사안을 보면 다시는 되돌릴 수 없는 정도의 것이 있지 않느냐면서 그것을 영변 핵폐기로 본다는 것이라며 이같이 말했습니다. \n 이 관계자는 그러면서 영변 핵폐기가 완전한 비핵화라는 게 아니라, 어느 단계를 되돌릴 수 없는 단계로 간주할 것인지가 협상의 핵심이 될 거라는 점이 대통령 인터뷰에 다 나와있다고 강조했습니다."),
            
            MemoData(date: date, text: "톱스타 부부인 송중기와 송혜교가 결혼한 지 1년8개월 만에 파경을 맞았습니다. 송중기는 법률대리인인 법무법인, 광장을 통해 어제 서울가정법원에 송혜교와의 이혼조정을 신청했다고 밝혔습니다. 이어 소속사를 통해 사생활에 대한 이야기들을 하나하나 말씀드리기 어려운 점 양해 부탁드리고, 앞으로 저는 지금의 상처에서 벗어나 연기자로서 작품 활동에 최선을 다하여 좋은 작품으로 보답하겠다고 밝혔습니다."),
            
            MemoData(date: date, text: "memo3"),
            MemoData(date: date, text: "memo4")
        ]
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
        return memoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemoListCell", for: indexPath) as! MemoListCell
        
        let formatter: DateFormatter = {
            let f = DateFormatter()
            f.dateStyle = .medium
            f.timeStyle = .none
            f.locale = Locale(identifier: "ko")
            return f
        }()
        
        cell.accessoryType = .disclosureIndicator
        cell.titleLabel.text = memoArray[indexPath.row].returnTitle()
        cell.dateLabel.text = formatter.string(from: memoArray[indexPath.row].date)
        cell.descriptionLabel.text = memoArray[indexPath.row].returnBody()
        cell.noteIcon.image = UIImage(named: "noteIcon")
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            
            success(true)
        }
        
        deleteAction.image = UIImage(named: "trash")
        
        
        let pinTopAction = UIContextualAction(style: .normal, title: "핀 고정") { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            
            success(true)
        }
        
        pinTopAction.image = UIImage(named: "pin")
        pinTopAction.backgroundColor = .black
        
        return UISwipeActionsConfiguration(actions: [deleteAction, pinTopAction])
    }
}

// MARK: - UITableViewDelegate

extension MemoListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailMemoVC = DetailMemoViewController()
        navigationController?.pushViewController(detailMemoVC, animated: true)
    }
    
}

// MARK: - UISearchResultsUpdating

extension MemoListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

// MARK: - UISearchBarDelegate

extension MemoListViewController: UISearchBarDelegate {
    
}
