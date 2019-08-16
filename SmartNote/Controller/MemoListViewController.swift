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
    
    let titleImageView = UIImageView(image: UIImage(named: "smartmemo_black"))
    var searchController = UISearchController(searchResultsController: nil)
    let tableView = UITableView()
    
    var isStart = false
    var memoArray = [MemoData]()
    var filteredMemoArray = [MemoData]()
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let noti = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setAutoLayout()
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
        view.backgroundColor = .white
        navigationItem.titleView = titleImageView
        titleImageView.contentMode = .scaleAspectFit
        
        title = "Memo"
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        searchController.searchBar.text = ""
        searchController.searchBar.placeholder = "검색"
        searchController.obscuresBackgroundDuringPresentation = false
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MemoListCell.self, forCellReuseIdentifier: "MemoListCell")
        tableView.rowHeight = 60
        tableView.backgroundColor = .white
        tableView.separatorColor = UIColor(red:0.30, green:0.82, blue:0.88, alpha:0.6)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 10)
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
    
    func getCoreData() {        // 저장된 CoreData에서 불러와 테이블뷰에 뿌려줄 memoArray에 값 추가해주는 메소드
        memoArray.removeAll()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MemoCoreData")
        
        do {
            let objects = try managedObjectContext.fetch(request) as! [NSManagedObject]
            print("🔵🔵🔵 Load Data: ", objects)
            
            guard objects.count > 0 else { print("There's no objects"); return }
            for nsManagedObject in objects {
                guard let coreData = nsManagedObject as? MemoCoreData else { print("coreData convert Error"); return }
                
                print("Date: \(coreData.date!) / UniqueKey: \(coreData.uniqueKey!) / Text: \(coreData.text!) / isPinned: \(coreData.isPinned) / isLocked: \(coreData.isLocked)")
                
                let memoDataFromCoreData = convertMemoDataFromCoreData(coreData)
                
                memoDataFromCoreData.isPinned ? memoArray.insert(memoDataFromCoreData, at: 0) : memoArray.append(memoDataFromCoreData)
                // isPinned가 true이면 memoArray에 가장 첫번째 행에 insert(tableView의 가장 상단에 위치) false이면 그냥 맨 뒤에 append
            }
            
        }catch let error as NSError {
            print("‼️‼️‼️ : ", error.localizedDescription)
        }
        self.tableView.reloadData()
    }
}


// MARK: - UITableViewDataSource

extension MemoListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch isStart {
        case true:
            return filteredMemoArray.count
        case false:
            return memoArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // searchbar 초기값과 검색후에 테이블에 뿌려줄 데이터 어레이 바꿔주려고
        var data = [MemoData]()
        
        switch isStart {
        case true:
            data = filteredMemoArray
        case false:
            data = memoArray
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemoListCell", for: indexPath) as! MemoListCell
        
        let formatter: DateFormatter = {
            let f = DateFormatter()
            f.dateStyle = .medium
            f.timeStyle = .none
            f.locale = Locale(identifier: "ko")
            return f
        }()
        
        cell.selectionStyle = .none
        cell.titleLabel.text = data[indexPath.row].returnTitleAndBody().0
        cell.descriptionLabel.text = data[indexPath.row].isLocked ? "잠김" : data[indexPath.row].returnTitleAndBody().1
        cell.dateLabel.text = formatter.string(from: data[indexPath.row].date)
        cell.noteIcon.image = UIImage(named: "noteIcon")
        cell.pinImageView.image = data[indexPath.row].isPinned ? UIImage(named: "isPinned") : UIImage()
        cell.lockedImageView.image = data[indexPath.row].isLocked ? UIImage(named: "lock_black") : UIImage()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let currentMemoUniqueKey = self.memoArray[indexPath.row].uniqueKey   // 현재 선택한 셀의 UniqueKey
        
        // 삭제 버튼 클릭시
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { (ac: UIContextualAction, view: UIView, success: @escaping (Bool) -> Void) in
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MemoCoreData")
            let pred = NSPredicate(format: "(uniqueKey = %@)", currentMemoUniqueKey)
            request.predicate = pred
            
            func deleteAlert(title: String, message: String) {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
                alert.addTextField(configurationHandler: { textField in
                    textField.placeholder = "암호"
                    textField.isSecureTextEntry = true
                })
                
                let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                    
                    if alert.textFields?.first?.text == self.memoArray[indexPath.row].password {
                        
                        do {
                            print("password correct")
                            let objects = try self.managedObjectContext.fetch(request) as! [NSManagedObject]
                            guard objects.count > 0 else { print("There's no objects"); return }
                            self.managedObjectContext.delete(objects.first!)
                            try self.managedObjectContext.save()
                            success(true)
                        } catch let error as NSError {
                            print("‼️‼️‼️ : ", error.localizedDescription)
                        }
                
                    } else {
                        
                        deleteAlert(title: "메모 삭제", message: "암호가 올바르지 않습니다. 다시 시도하십시오.")
                        success(false)
                    }
                }
                
                let cancelAction = UIAlertAction(title: "취소", style: .cancel)
                
                alert.addAction(okAction); alert.addAction(cancelAction)
                self.present(alert, animated: true)
            }
            
            
            if self.memoArray[indexPath.row].isLocked == true {
                deleteAlert(title: "메모 삭제", message: "잠긴 메모를 삭제하려면 사용자의 현재 암호를 입력하십시오.")

            } else {
                do {
                    let objects = try self.managedObjectContext.fetch(request) as! [NSManagedObject]
                    guard objects.count > 0 else { print("There's no objects"); return }
                    self.managedObjectContext.delete(objects.first!)
                    try self.managedObjectContext.save()
                    
                } catch let error as NSError {
                    print("‼️‼️‼️ : ", error.localizedDescription)
                }
                success(true)
            }
        }
        
        
        
        deleteAction.image = UIImage(named: "trash")
        deleteAction.backgroundColor = UIColor(red:0.72, green:0.11, blue:0.11, alpha:1.0)
        
        
        // 핀고정 버튼 클릭시
        let pinTopAction = UIContextualAction(style: .normal, title: "핀 고정") { (ac: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MemoCoreData")
            let pred = NSPredicate(format: "(uniqueKey = %@)", currentMemoUniqueKey)
            request.predicate = pred
            
            do {
                let objects = try self.managedObjectContext.fetch(request) as! [NSManagedObject]
                guard objects.count > 0 else { print("There's no objects"); return }
                
                let value = self.memoArray[indexPath.row].isPinned ? false : true // 현재 isPinned값이 true이면 false로, false이면 true로 변경하여 저장
                objects.first!.setValue(value, forKey: "isPinned")
                
                try self.managedObjectContext.save()
            }catch let error as NSError {
                print("‼️‼️‼️ : ", error.localizedDescription)
            }
            
            if self.memoArray[indexPath.row].isPinned == false {    // isPinned false=>True 핀하려고 눌렀을때
                // =================================== 시간차를 두고 Action을 주기위한 방법1  ===================================
//                let group = DispatchGroup()
//                let queue1 = DispatchQueue.main
//                let queue2 = DispatchQueue(label: "queue2")
//
//                queue1.async(group: group) {
//                    UIView.animate(withDuration: 0.7, animations: {
//                        self.tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 0))
//
//                    })
//                }
//
//                queue2.async(group: group) {
////                    for _ in 0...10000 { _ = 1 + 1 }
//                    UIView.animate(withDuration: 0.7, delay: 1, options: [], animations: {
//
//                    })
//                }
//
//                group.notify(queue: .main, execute: {
//                    self.getCoreData()
//                })
                
                // =================================== 방법2 ===================================
                UIView.animate(withDuration: 0.7, animations: {
                    self.tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 0))
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                    self.getCoreData()
                })
                // =================================== ===================================
                
                
              
                
                
            } else {    // 핀설정을 해제할때
                var indexAfterPinnedOut = 0
                
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MemoCoreData")
                
                do {
                    let objects = try self.managedObjectContext.fetch(request) as! [NSManagedObject]
                    
                    guard objects.count > 0 else { print("There's no objects"); return }
                    
                    var pinnedMemoDatasBehindCurrentMemoData = 0   // CoreData에서 내가 핀해제하려는 Memo데이터 뒤에 pinned되어있는 메모가 몇개있는지 세어주기위함
                    for index in (0..<objects.count).reversed() {
                        
                        guard let coreData = objects[index] as? MemoCoreData else { print("coreData convert Error"); return }
                        guard coreData.isPinned == false else { pinnedMemoDatasBehindCurrentMemoData += 1; continue }
                        
                        if self.memoArray[indexPath.row].uniqueKey == coreData.uniqueKey {
                            indexAfterPinnedOut = index + pinnedMemoDatasBehindCurrentMemoData
                            // pinnedMemoDatasBehindCurrentMemoData를 더해준 이유: 내뒤에 있는 메모들이 핀되었다면 앞의 index로 이동해있을 것이기때문에
                            // 그만큼 더해준 index의 위치로 이동시키기 위함
                        }
                    }
                    
                }catch let error as NSError {
                    print("‼️‼️‼️ : ", error.localizedDescription)
                }
                
                UIView.animate(withDuration: 0.7, animations: {
                    self.tableView.moveRow(at: indexPath, to: IndexPath(row: indexAfterPinnedOut, section: 0))
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                    self.getCoreData()
                })
            }
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
        
        lockAction.image = memoArray[indexPath.row].isLocked ? UIImage(named: "unlock") : UIImage(named: "lock")
            
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
        
        var data = [MemoData]()

        switch isStart {
        case true:
            data = filteredMemoArray
        case false:
            data = memoArray
        }
        
        let detailMemoVC = DetailMemoViewController()
        detailMemoVC.detailMemo = data[indexPath.row]
        
        // 메모가 잠겨있는 상태이면
        if data[indexPath.row].isLocked == true {
            
            let alert = UIAlertController(title: "This is locked Memo", message: "Input your Password", preferredStyle: .alert)
            
            let action1 = UIAlertAction(title: "OK", style: .default) { _ in
                // 비밀번호 재확인 Alert창
                guard alert.textFields?.first?.text == data[indexPath.row].password else {
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
            searchController.dismiss(animated: true)
            navigationController?.pushViewController(detailMemoVC, animated: true)
        }
    }
}

// MARK: - UISearchResultsUpdating

extension MemoListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {}

}

// MARK: - UISearchBarDelegate

extension MemoListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == "" {
            filteredMemoArray = memoArray
            isStart = false
        } else if !searchText.isEmpty {
            filteredMemoArray = memoArray.filter { $0.text.contains(searchText) }
        }
        
        isStart = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredMemoArray = memoArray
        tableView.reloadData()
    }
}
