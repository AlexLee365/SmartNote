//
//  MemoViewController.swift
//  SmartNote
//
//  Created by 행복한 개발자 on 26/06/2019.
//  Copyright © 2019 Alex Lee. All rights reserved.
//

import UIKit
import MobileCoreServices

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
