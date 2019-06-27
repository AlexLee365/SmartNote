//
//  MemoListViewController.swift
//  SmartNote
//
//  Created by 행복한 개발자 on 26/06/2019.
//  Copyright © 2019 Alex Lee. All rights reserved.
//
import UIKit
import CoreData

class MemoListViewController: UIViewController {
    
    let titleImageView = UIImageView(image: UIImage(named: "smartmemo"))
    let searchController = UISearchController(searchResultsController: nil)
    let tableView = UITableView()
    
    var memoArray = [MemoData]()
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setAutoLayout()
        
    }
    
    func getCoreData() {        // 저장된 CoreData에서 불러와 테이블뷰에 뿌려줄 memoArray에 값 추가해주는 메소드
        memoArray.removeAll()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MemoCoreData")
        
        do {
            let objects = try managedObjectContext.fetch(request) as! [NSManagedObject]
            print("🔵🔵🔵 Load Data: ", objects)
            
            guard objects.count > 0 else { print("There's no objects"); return }
            for nsManagedObject in objects {
                guard let coreData = nsManagedObject as? MemoCoreData else { print("coreData convert Error"); return }
                
                print("Date: \(coreData.date!) / UniqueKey: \(coreData.uniqueKey!) / Text: \(coreData.text!)")
                
                let memoDataFromCoreData = convertMemoDataFromCoreData(coreData)
                memoArray.append(memoDataFromCoreData)
            }
            
        }catch let error as NSError {
            print("‼️‼️‼️ : ", error.localizedDescription)
        }
        tableView.reloadData()
    }
    
    // shows search bar without scrolling up
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getCoreData()
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    // hides search bar when scrolling down
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    
    // MARK: - configuration
    
    private func configure() {
        //        navigationItem.titleView = titleImageView
        //        titleImageView.contentMode = .scaleAspectFit
        
        title = "Memo"
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        searchController.searchBar.placeholder = "검색"
        searchController.obscuresBackgroundDuringPresentation = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MemoListCell.self, forCellReuseIdentifier: "MemoListCell")
        tableView.rowHeight = 60
        tableView.backgroundColor = .white
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
        
        cell.selectionStyle = .none
        cell.titleLabel.text = memoArray[indexPath.row].returnTitleAndBody().0
        cell.descriptionLabel.text = memoArray[indexPath.row].returnTitleAndBody().1
        cell.dateLabel.text = formatter.string(from: memoArray[indexPath.row].date)
        cell.noteIcon.image = UIImage(named: "noteIcon")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let currentMemoUniqueKey = self.memoArray[indexPath.row].uniqueKey   // 현재 선택한 셀의 UniqueKey
        
        // 삭제 버튼 클릭시
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MemoCoreData")
            let pred = NSPredicate(format: "(uniqueKey = %@)", currentMemoUniqueKey)
            request.predicate = pred

            do {
                let objects = try self.managedObjectContext.fetch(request) as! [NSManagedObject]
                guard objects.count > 0 else { print("There's no objects"); return }
                self.managedObjectContext.delete(objects.first!)
                try self.managedObjectContext.save()
                
            }catch let error as NSError {
                print("‼️‼️‼️ : ", error.localizedDescription)
            }
            success(true)
        }
        
        deleteAction.image = UIImage(named: "trash")
        deleteAction.backgroundColor = UIColor(red:0.72, green:0.11, blue:0.11, alpha:1.0)
        
        // 핀고정 버튼 클릭시
        let pinTopAction = UIContextualAction(style: .normal, title: "핀 고정") { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            
            
            
            success(true)
        }
        pinTopAction.image = UIImage(named: "pin")
        pinTopAction.backgroundColor = UIColor(red:0.00, green:0.72, blue:0.83, alpha:1.0)
        
        // 잠금버튼 클릭시
        let lockAction =  UIContextualAction(style: .normal, title: "잠금") { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            
            let alert = UIAlertController(title: "Lock the Memo", message: "Input your Password", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "OK", style: .default) { _ in
                // 비밀번호 재확인 Alert창
                guard !alert.textFields!.first!.text!.isEmpty
                    else { self.makeAlert(title: "Message", message: "Please Input Password"); return;}
                
                alert.dismiss(animated: true, completion: nil)
                
                let alertAgain = UIAlertController(title: "Check Passwords", message: "Input your Password again", preferredStyle: .alert)
                let action1 = UIAlertAction(title: "OK", style: .default) { _ in
                    if alert.textFields?.first?.text == alertAgain.textFields?.first?.text {
                        // 첫번째 Alert에서 입력한 비밀번호와 두번째 Alert에서 입력한 비밀번호가 같을때
                        
                        // 잠금된 정보를 Upload
                        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MemoCoreData")
                        let pred = NSPredicate(format: "(uniqueKey = %@)", currentMemoUniqueKey)
                        request.predicate = pred
                        
                        do {
                            let objects = try self.managedObjectContext.fetch(request) as! [NSManagedObject]
                            
                            guard objects.count > 0 else { print("There's no objects"); return }
                            objects.first!.setValue(alertAgain.textFields?.first?.text, forKey: "password")
                            objects.first!.setValue(true, forKey: "isLocked")
                            try self.managedObjectContext.save()
                        }catch let error as NSError {
                            print("‼️‼️‼️ : ", error.localizedDescription)
                        }
                        
                        self.getCoreData()   // 수정된 데이터로 다시 테이블뷰로 뿌려줌
                        
                    } else {
                        // 틀렸을때
                        self.makeAlert(title: "Failed", message: "Wrong Password")
                    }
                }
                let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertAgain.addTextField { (textField) in
                    textField.placeholder = "비밀번호를 한번 더 입력하세요"
                    textField.isSecureTextEntry = true
                }
                
                
                alertAgain.addAction(action1); alertAgain.addAction(action2)
                self.present(alertAgain, animated: true)
            }
            let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addTextField { (textField) in
                textField.placeholder = "비밀번호를 입력하세요"
                textField.isSecureTextEntry = true
            }
            
            
            alert.addAction(action1); alert.addAction(action2)
            self.present(alert, animated: true)
            
            success(true)
        }
        lockAction.image = UIImage(named: "lock")
        lockAction.backgroundColor = UIColor(red:1.00, green:0.84, blue:0.31, alpha:1.0)
        
        
        
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, pinTopAction, lockAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "OK", style: .default) { _ in }
        
        alert.addAction(action1)
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate

extension MemoListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailMemoVC = DetailMemoViewController()
        detailMemoVC.detailMemo = memoArray[indexPath.row]
        
        // 메모가 잠겨있는 상태이면
        if memoArray[indexPath.row].isLocked == true {
            
            let alert = UIAlertController(title: "This is locked Memo", message: "Input your Password", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "OK", style: .default) { _ in
                // 비밀번호 재확인 Alert창
                guard alert.textFields?.first?.text == self.memoArray[indexPath.row].password else {
                    self.makeAlert(title: "Failed", message: "This is Wrong Password")
                    alert.dismiss(animated: true, completion: nil)
                    return
                }
                self.navigationController?.pushViewController(detailMemoVC, animated: true)
            }
            let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addTextField { (textField) in
                textField.placeholder = "비밀번호를 입력하세요"
                textField.isSecureTextEntry = true
            }
            
            
            alert.addAction(action1); alert.addAction(action2)
            self.present(alert, animated: true)
            
        } else {
            navigationController?.pushViewController(detailMemoVC, animated: true)
        }
        
        
        
       
        
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
