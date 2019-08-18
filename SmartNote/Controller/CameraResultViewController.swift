//
//  CameraResultViewController.swift
//  SmartNote
//
//  Created by 행복한 개발자 on 04/07/2019.
//  Copyright © 2019 Alex Lee. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class CameraResultViewController: UIViewController, NVActivityIndicatorViewable {
    
    let cameraResultImageView = UIImageView()
    
    let retakeBtn = UIButton()
    let okBtn = UIButton()
    let cancelBtn = UIButton()
    
    var capturedImage = UIImage()
    
    let notiCenter = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("--------------------------[CameraResultVC view did load]--------------------------")
        setAutoLayout()
        configureViewsOptions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("--------------------------[CameraResultViewController]--------------------------")
        print("SafeInset: ", view.safeAreaInsets)
        print(self.presentingViewController)
        guard let priorVC = self.presentingViewController as? CameraViewController else { print("변환 실패"); return }
        //        priorVC.dismiss(animated: false, completion: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func setAutoLayout() {
        let safeGuide = view.safeAreaLayoutGuide
        
        view.addSubview(cameraResultImageView)
        cameraResultImageView.translatesAutoresizingMaskIntoConstraints = false
        cameraResultImageView.topAnchor.constraint(equalTo: safeGuide.topAnchor, constant: 40).isActive = true
        cameraResultImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        cameraResultImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        cameraResultImageView.heightAnchor.constraint(equalTo: cameraResultImageView.widthAnchor, multiplier: 1.25).isActive = true
        
        let bottomMargin: CGFloat = -40
        view.addSubview(cancelBtn)
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        cancelBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        cancelBtn.bottomAnchor.constraint(equalTo: safeGuide.bottomAnchor, constant: bottomMargin).isActive = true
        cancelBtn.widthAnchor.constraint(equalToConstant: 100).isActive = true
        cancelBtn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        view.addSubview(okBtn)
        okBtn.translatesAutoresizingMaskIntoConstraints = false
        okBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        okBtn.bottomAnchor.constraint(equalTo: safeGuide.bottomAnchor, constant: bottomMargin).isActive = true
        okBtn.widthAnchor.constraint(equalToConstant: 100).isActive = true
        okBtn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        view.addSubview(retakeBtn)
        retakeBtn.translatesAutoresizingMaskIntoConstraints = false
        retakeBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        retakeBtn.bottomAnchor.constraint(equalTo: safeGuide.bottomAnchor, constant: bottomMargin).isActive = true
        retakeBtn.widthAnchor.constraint(equalToConstant: 100).isActive = true
        retakeBtn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
    }
    
    private func configureViewsOptions() {
        view.backgroundColor = .black
        cameraResultImageView.contentMode = .scaleAspectFit
        cameraResultImageView.image = capturedImage
        
        let buttonTitleSize: CGFloat = 18
        let buttonWeight: UIFont.Weight = .light
        cancelBtn.setTitle("Cancel", for: .normal)
        cancelBtn.setTitleColor(.white, for: .normal)
        cancelBtn.titleLabel?.font = .systemFont(ofSize: buttonTitleSize, weight: buttonWeight)
        cancelBtn.addTarget(self, action: #selector(bottomBtnDidTap(_:)), for: .touchUpInside)
        
        okBtn.setTitle("OK", for: .normal)
        okBtn.setTitleColor(.white, for: .normal)
        okBtn.titleLabel?.font = .systemFont(ofSize: buttonTitleSize+4, weight: .regular)
        okBtn.addTarget(self, action: #selector(bottomBtnDidTap(_:)), for: .touchUpInside)
        
        retakeBtn.setTitle("Retake", for: .normal)
        retakeBtn.setTitleColor(.white, for: .normal)
        retakeBtn.titleLabel?.font = .systemFont(ofSize: buttonTitleSize, weight: buttonWeight)
        retakeBtn.addTarget(self, action: #selector(bottomBtnDidTap(_:)), for: .touchUpInside)
        
        
    }
    
    @objc func bottomBtnDidTap(_ sender: UIButton) {
        switch sender {
        case cancelBtn:
            print("Cancel")
            guard let cameraVC = self.presentingViewController as? CameraViewController else { print("변환 실패"); return }
            dismiss(animated: true)
            
            cameraVC.modalPresentationStyle = .overCurrentContext
            cameraVC.view.alpha = 0
            cameraVC.dismiss(animated: false, completion: nil)
            
            
            
        case okBtn:
            print("OK")
            guard let cameraVC = self.presentingViewController as? CameraViewController
                , let naviVC = cameraVC.presentingViewController as? UINavigationController
                , let memoVC = naviVC.viewControllers.first as? MemoViewController else {
                    print("OK버튼 변환 실패")
                    return
            }
            
            guard let image = capturedImage.resize(to: view.frame.size) else {
                print("‼️ caputredImage resize error ")
                return
            }
            
            let activityData = ActivityData(size: CGSize(width: 50, height: 50), message: "Converting", messageFont: .systemFont(ofSize: 14), messageSpacing: 10, type: .ballScaleMultiple, color: .white)
            NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
            
            GoogleCloudOCR().detect(from: image) { ocrResult in
                guard let ocrResult = ocrResult else { print("fixedImage ocrResult convert error!"); return }
                memoVC.memoView.textView.text = ocrResult.annotations.first?.text
                self.notiCenter.post(name: .memoTextViewEditingDidEnd, object: nil)
                
                print("텍스트 추출 결과 / ocrResult: ", ocrResult)
                
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                
                self.dismiss(animated: true)
                cameraVC.modalPresentationStyle = .overCurrentContext
                cameraVC.view.alpha = 0
                cameraVC.dismiss(animated: false, completion: nil)
            }
            
            
            
        case retakeBtn:
            dismiss(animated: true, completion: nil)
            
            
            
        default: break
        }
    }
    
    
    
}
