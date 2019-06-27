//
//  MemoViewController.swift
//  SmartNote
//
//  Created by 행복한 개발자 on 26/06/2019.
//  Copyright © 2019 Alex Lee. All rights reserved.
//

import UIKit
import MobileCoreServices
import Alamofire
import CoreData

class MemoViewController: UIViewController {
    
    // MARK: - Properties
    let memoView = MemoView()
    let notiCenter = NotificationCenter.default
    
    let defaultRightBarBtn = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(rightBarBtnDidTap(_:)))
    let completeRightBarBtn = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(rightBarBtnDidTap(_:)))
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func loadView() {
        view = memoView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        

//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MemoCoreData")
////        e8EmFSzD7S
////        let pred = NSPredicate(format: "(uniqueKey = %@)", "e8EmFSzD7S")
////        request.predicate = pred
//
//        do {
//            let objects = try managedObjectContext.fetch(request) as! [NSManagedObject]
//            print("🔵🔵🔵 Load Data: ", objects)
//
//            guard objects.count > 0 else { print("There's no objects"); return }
//            for nsManagedObject in objects {
//                guard let coreData = nsManagedObject as? MemoCoreData else { print("coreData convert Error"); return }
//                let a = convertMemoDataFromCoreData(coreData)
//                print(a.uniqueKey)
//                print(a.text)
//                print(a.date)
//            }
//
//
//
//        }catch let error as NSError {
//            print("‼️‼️‼️ : ", error.localizedDescription)
//        }
        
        
        
        
        
        configureViewsOptions()
        addNotificationObserver()
    }
    
    private func setAutoLayout() {
        let safeGuide = view.safeAreaLayoutGuide
    }
    
    private func configureViewsOptions() {
        let titleImageView = UIImageView(image: UIImage(named: "smartmemo"))
        navigationItem.titleView = titleImageView
        titleImageView.contentMode = .scaleAspectFit
        
        
        memoView.cameraBtn.addTarget(self, action: #selector(cameraBtnDidTap(_:)), for: .touchUpInside)
        memoView.albumBtn.addTarget(self, action: #selector(albumBtnDidTap(_:)), for: .touchUpInside)

        
        
        navigationItem.rightBarButtonItem = defaultRightBarBtn
        
        
        let swipeFromRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(_:)))
        swipeFromRight.direction = .right
        view.addGestureRecognizer(swipeFromRight)
        
        let swipeFromLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(_:)))
        swipeFromLeft.direction = .left
        view.addGestureRecognizer(swipeFromLeft)
    }
    
    func addNotificationObserver() {
        notiCenter.addObserver(self, selector: #selector(didReceiveNotification(_:)), name: NSNotification.Name("textViewEditing"), object: nil)
        notiCenter.addObserver(self, selector: #selector(didReceiveNotification(_:)), name: NSNotification.Name("textViewEditingEnd"), object: nil)
        notiCenter.addObserver(self, selector: #selector(didReceiveNotification(_:)), name: NSNotification.Name("textViewEditingEndButEmpty"), object: nil)
    }
    
    @objc func didReceiveNotification(_ sender: Notification) {
        switch sender.name {
        case Notification.Name("textViewEditing") :
            print("textViewEditing")
            navigationItem.rightBarButtonItem = completeRightBarBtn
            
        case Notification.Name("textViewEditingEnd"):
            print("textViewEditingEnd")
            let saveRightBarBtn = UIBarButtonItem(title: "저장", style: .plain, target: self, action: #selector(rightBarBtnDidTap(_:)))
            navigationItem.rightBarButtonItem = saveRightBarBtn

        case Notification.Name("textViewEditingEndButEmpty"):
            print("textViewEditingEndButEmpty")
            navigationItem.rightBarButtonItem = defaultRightBarBtn
        default : break
        }
    }
    
    
    @objc func cameraBtnDidTap(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            presentImagePickerController(withSourceType: .camera)
        } else {
            let alert = UIAlertController(title: "Camera Not Available", message: "A camera is not available. Please try picking an image from the image library instead.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func albumBtnDidTap(_ sender: UIButton) {
        presentImagePickerController(withSourceType: .photoLibrary)
    }
    
    
    @objc func rightBarBtnDidTap(_ sender: UIBarButtonItem) {
        
        if navigationItem.rightBarButtonItem?.title == "저장" {  // 저장 버튼 클릭시
            print("--------------------------[저장버튼 클릭]--------------------------")
            let date = Date()
            let text = memoView.textView.text ?? ""
            
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "yyyy. M. d"
//            dateFormatter.locale = Locale(identifier: "ko")
//
//            let currentDateString = dateFormatter.string(from: date)
//            print("현재 시간: ", currentDateString)
//            print("랜덤문자생성: ", makeRandomString())
            
            
            let memoData = MemoData(date: date, text: text)
            
            let entityDescription = NSEntityDescription.entity(forEntityName: "MemoCoreData", in: managedObjectContext)
            let memoCoreDataObject = MemoCoreData(entity: entityDescription!, insertInto: managedObjectContext)
            
            saveCoreDataFromMemoData(coreData: memoCoreDataObject, memoData: memoData)
            
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                print("‼️‼️‼️ : ", error.localizedDescription)
            }
            print("🔵🔵🔵 managedObjectContext: ", managedObjectContext)
            print(memoCoreDataObject)
            
            
        } else {
            memoView.textView.resignFirstResponder()
            
        }
    }
    
    @objc func respondToSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        print("--------------------------[memoVC respondSwipeGesture]--------------------------")
        switch gesture.direction {
        case .left:
            let memoListVC = MemoListViewController()
            navigationController?.pushViewController(memoListVC, animated: true)
        case .right:
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                presentImagePickerController(withSourceType: .camera)
            } else {
                let alert = UIAlertController(title: "Camera Not Available", message: "A camera is not available. Please try picking an image from the image library instead.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        default: break
        }
        
       
    }
    
}

extension MemoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func presentImagePickerController(withSourceType sourceType: UIImagePickerController.SourceType) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = sourceType
        controller.mediaTypes = [String(kUTTypeImage)]
        present(controller, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {

            self.memoView.textView.text = ""
//            let fixedImage = pickedImage.fixOrientation()
            let fixedImage = pickedImage
            
            guard let fixedImage2 = fixedImage.resize(to: view.frame.size) else {
                fatalError("Error resizing image")
            }
            
            
            GoogleCloudOCR().detect(from: fixedImage2) { ocrResult in
                guard let ocrResult = ocrResult else { print("fixedImage ocrResult convert error!"); return }
                print("viewcontroller ocrResult: ", ocrResult)
                
                ocrResult.annotations.forEach{
                    self.memoView.textView.text += $0.text
                }
            }
        }
        memoView.textView.centerVertically()
        memoView.isTextViewHasText = true
        dismiss(animated: true, completion: nil)
        
    }
    
    
}



fileprivate func makeRandomString() -> String {
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let length = UInt32(letters.length)
    
    var randomString = ""
    
    for _ in 0 ..< 10 {
        let rand = arc4random_uniform(length)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    
    return randomString
}
