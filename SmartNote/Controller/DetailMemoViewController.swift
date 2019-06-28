//
//  DetailMemoViewController.swift
//  SmartNote
//
//  Created by Solji Kim on 27/06/2019.
//  Copyright © 2019 Alex Lee. All rights reserved.
//

import UIKit
import CoreData

class DetailMemoViewController: UIViewController {
    
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        f.locale = Locale(identifier: "ko")
        return f
    }()
    
    let detailTextView = UITextView()
    let lastEditedLabel = UILabel()
    let dateLabel = UILabel()

    var detailMemo: MemoData?
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        configure()
        setAutolayout()
    }
    
    private func configure() {
        
        detailTextView.delegate = self
        
        let shareRightBarBtn = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonDidTap(_:)))
        
        navigationItem.rightBarButtonItems = [shareRightBarBtn]
        
        detailTextView.backgroundColor = .clear
        detailTextView.font = UIFont(name: "Binggrae", size: 17)
        detailTextView.text = detailMemo?.text
        detailTextView.autocorrectionType = .no
        view.addSubview(detailTextView)
        
        lastEditedLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        lastEditedLabel.text = "마지막 수정"
        lastEditedLabel.textColor = .lightGray
        view.addSubview(lastEditedLabel)
        
        dateLabel.textColor = .lightGray
        dateLabel.font = UIFont.systemFont(ofSize: 15)
        dateLabel.text = formatter.string(from: detailMemo!.date)
        view.addSubview(dateLabel)
    }
    
    
    @objc func completeRightBarBtnDidTap(_ sender: UIBarButtonItem) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MemoCoreData")
        let pred = NSPredicate(format: "(uniqueKey = %@)", detailMemo!.uniqueKey)
        request.predicate = pred
        
        do {
            let objects = try managedObjectContext.fetch(request) as! [NSManagedObject]
            let date = Date()
            let nsDate = NSDate()
            guard objects.count > 0 else { print("There's no objects"); return }
            objects.first!.setValue(detailTextView.text, forKey: "text")
            objects.first!.setValue(nsDate, forKey: "date")
            dateLabel.text = formatter.string(from: date)
            try managedObjectContext.save()
        }catch let error as NSError {
            print("‼️‼️‼️ : ", error.localizedDescription)
        }
        
        detailTextView.resignFirstResponder()
    }
    
    
    @objc func shareButtonDidTap(_ sender: UIBarButtonItem) {
        
        let vc = UIActivityViewController(
            activityItems: [detailTextView.text ?? ""],
            applicationActivities: [])
        
        present(vc, animated: true, completion: nil)
    }
    
    
    private func setAutolayout() {
        let guide = view.safeAreaLayoutGuide
        
        detailTextView.translatesAutoresizingMaskIntoConstraints = false
        detailTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10).isActive = true
        detailTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        detailTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        detailTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        lastEditedLabel.translatesAutoresizingMaskIntoConstraints = false
        lastEditedLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        lastEditedLabel.topAnchor.constraint(equalTo: guide.topAnchor, constant: 10).isActive = true
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dateLabel.topAnchor.constraint(equalTo: lastEditedLabel.bottomAnchor, constant: 2).isActive = true
    }
}


// MARK: - UITextViewDelegate

extension DetailMemoViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("--------------------------[MemoView textView Did Begin Editing]--------------------------")
        
        let completeRightBarBtn = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(completeRightBarBtnDidTap))
        let shareRightBarBtn = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonDidTap(_:)))
        
        navigationItem.rightBarButtonItems = [completeRightBarBtn, shareRightBarBtn]
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("--------------------------[MemoView textView Did End Editing]--------------------------")
        
        let shareRightBarBtn = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonDidTap(_:)))
        navigationItem.rightBarButtonItems = [shareRightBarBtn]
        
    }
}
