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

class MemoViewController: UIViewController {
    
    let memoView = MemoView()
    
    override func loadView() {
        view = memoView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewsOptions()
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
        memoView.translateBtn.addTarget(self, action: #selector(translateBtnDidTap(_:)), for: .touchUpInside)
        
        let rightBarBtn = UIBarButtonItem(title: "수정", style: .plain, target: self, action: #selector(rightBarBtnDidTap(_:)))
        
        
        navigationItem.rightBarButtonItem = rightBarBtn
        
        
        let swipeFromRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(_:)))
        swipeFromRight.direction = .right
        view.addGestureRecognizer(swipeFromRight)
        
        let swipeFromLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(_:)))
        swipeFromLeft.direction = .left
        view.addGestureRecognizer(swipeFromLeft)
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
    
    @objc func translateBtnDidTap(_ sender: UIButton) {
        let queryValue = memoView.textView.text ?? ""
        var languageTranslateFrom = "kr"
        var languageTranslateTo = "en"
        
        let urlString = "https://kapi.kakao.com/v1/translation/translate?"
            + "app_key=e4e4abd79709fdbc4e04e732818ac6f1&"
            + "src_lang=\(languageTranslateFrom)&"
            + "target_lang=\(languageTranslateTo)&"
            + "query=\(queryValue)"
        
        guard let translateAPIString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let convertUrl = URL(string: translateAPIString)
            else { print("convertUrl failed"); return }
        
        AF.request(convertUrl).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                
                guard let dicValue = value as? [String: Any], let textDataArray = dicValue["translated_text"] as? [[String]]
                    else { print("textDataArray convert error"); return }
                print("🔵🔵🔵  ", textDataArray)
                
                var text = ""
                textDataArray.map{ $0.first ?? ""}.forEach{
                    text += $0
                }
                print("🔵🔵🔵  ", text)
                
                
                self.memoView.textView.text = text
                
            case .failure(let error):
                print(error)
            }
        }
        
        
        
        
        
    }
    
    @objc func rightBarBtnDidTap(_ sender: UIBarButtonItem) {
        memoView.textView.resignFirstResponder()
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
