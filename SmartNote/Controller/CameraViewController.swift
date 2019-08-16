//
//  CameraViewController.swift
//  SmartNote
//
//  Created by 행복한 개발자 on 04/07/2019.
//  Copyright © 2019 Alex Lee. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {
    
    let cameraController = CameraController()
    
    private let cameraCapturePreview = UIView()
    private let cameraCaptureBtn = UIButton()
    
    let customTransitionDelegate = TransitioningDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAutoLayout()
        configureViewsOptions()
        
        configureCameraController()
        
        modalPresentationStyle = .custom
        transitioningDelegate = customTransitionDelegate
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        print("--------------------------[CameraViewController]--------------------------")
        print("SafeInset: ", view.safeAreaInsets)
        print("CameraCapturePreView 좌표: ", cameraCapturePreview.frame.origin)
        
        cameraCaptureBtn.layer.borderColor = UIColor.white.cgColor
        cameraCaptureBtn.layer.borderWidth = 2
        cameraCaptureBtn.layer.cornerRadius = min(cameraCaptureBtn.frame.width, cameraCaptureBtn.frame.height) / 2
    }
    
    private func setAutoLayout() {
        let safeGuide = view.safeAreaLayoutGuide
        
        view.addSubview(cameraCapturePreview)
        cameraCapturePreview.translatesAutoresizingMaskIntoConstraints = false
        cameraCapturePreview.topAnchor.constraint(equalTo: safeGuide.topAnchor, constant: 0).isActive = true
        cameraCapturePreview.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        cameraCapturePreview.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        cameraCapturePreview.heightAnchor.constraint(equalTo: cameraCapturePreview.widthAnchor, multiplier: 1.25).isActive = true
        
        view.addSubview(cameraCaptureBtn)
        cameraCaptureBtn.translatesAutoresizingMaskIntoConstraints = false
        cameraCaptureBtn.bottomAnchor.constraint(equalTo: safeGuide.bottomAnchor, constant: -50).isActive = true
        cameraCaptureBtn.centerXAnchor.constraint(equalTo: safeGuide.centerXAnchor).isActive = true
        cameraCaptureBtn.widthAnchor.constraint(equalToConstant: 60).isActive = true
        cameraCaptureBtn.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        view.bringSubviewToFront(cameraCaptureBtn)
    }
    
    private func configureViewsOptions() {
        view.backgroundColor = .black
        
        cameraCaptureBtn.addTarget(self, action: #selector(captureImage(_:)), for: .touchUpInside)
        
        let swipeFromLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeFromLeft.direction = .left
        view.addGestureRecognizer(swipeFromLeft)
    }
    
    private func configureCameraController() {
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }
            
            try? self.cameraController.displayPreview(on: self.cameraCapturePreview)
        }
    }
    
    @objc func respondToSwipeGesture() {
        let transition = CATransition()
        transition.duration = 0.15
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        //        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        
        dismiss(animated: false, completion: nil)
    }
    
    
    @objc func captureImage(_ sender: UIButton) {
        cameraController.captureImage {(image, error) in
            
            guard var image = image else {
                print(error ?? "Image capture error")
                return
            }
            
            // 이미지 저장하는 코드 => import Photos 필요
            //            try? PHPhotoLibrary.shared().performChangesAndWait {
            //                PHAssetChangeRequest.creationRequestForAsset(from: image)
            //            }
            
            let resultVC = CameraResultViewController()
            
            image = image.cropImage(viewFrameToScaleFromImage: self.cameraCapturePreview.frame)!
            
            resultVC.capturedImage = image
            print("captrue image size: ", image.size)
            
            //            guard let currentVC = self as? CameraViewController else { print("변환실패"); return }
            
            self.present(resultVC, animated: true, completion: { [weak self] in
                guard let priorVC = self?.presentingViewController as? CameraViewController else { print("변환 실패"); return }
                priorVC.dismiss(animated: true, completion: nil)
            })
            
        }
    }
    
    
    
    
}
