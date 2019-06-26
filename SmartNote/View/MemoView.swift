//
//  MemoView.swift
//  SmartNote
//
//  Created by 행복한 개발자 on 26/06/2019.
//  Copyright © 2019 Alex Lee. All rights reserved.
//

import UIKit

class MemoView: UIView {
    
    // MARK: - UI Properties
    let textView = UITextView()
    let albumBtn = UIButton()
    let cameraBtn = UIButton()
    let translateBtn = UIButton()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("--------------------------[MemoView init]--------------------------")
        
        setAutoLayout()
        configureViewsOptions()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    private func setAutoLayout() {
        print("--------------------------[MemoView setAutoLayout]--------------------------")
        
        let buttonSpacing = UIScreen.main.bounds.width/4
        let buttonSize: CGFloat = 50
        
        self.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        textView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -150).isActive = true
        
        self.addSubview(translateBtn)
        translateBtn.translatesAutoresizingMaskIntoConstraints = false
        translateBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        translateBtn.centerYAnchor.constraint(equalTo: self.bottomAnchor, constant: -80).isActive = true
        translateBtn.widthAnchor.constraint(equalToConstant: buttonSize+20).isActive = true
        translateBtn.heightAnchor.constraint(equalToConstant: buttonSize+20).isActive = true
        
        self.addSubview(albumBtn)
        albumBtn.translatesAutoresizingMaskIntoConstraints = false
        albumBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: -buttonSpacing).isActive = true
        albumBtn.centerYAnchor.constraint(equalTo: translateBtn.centerYAnchor).isActive = true
        albumBtn.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        albumBtn.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        
        self.addSubview(cameraBtn)
        cameraBtn.translatesAutoresizingMaskIntoConstraints = false
        cameraBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: buttonSpacing).isActive = true
        cameraBtn.centerYAnchor.constraint(equalTo: translateBtn.centerYAnchor).isActive = true
        cameraBtn.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        cameraBtn.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        
    }
    
    private func configureViewsOptions() {
        print("--------------------------[MemoView configureViewOptions]--------------------------")
        textView.backgroundColor = .orange
        
        albumBtn.backgroundColor = .blue
        cameraBtn.backgroundColor = .cyan
//        translateBtn.backgroundColor = UIColor(red:0.00, green:0.72, blue:0.83, alpha:1.0)
//        translateBtn.backgroundColor = .yellow
        
        
        
        translateBtn.setImage(UIImage(named: "transIcon"), for: .normal)
        
//        translateBtn.setImage(UIImage(named: "transIcon"), for: .normal)
        
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        print("--------------------------[MemoView didMoveToSuperView]--------------------------")
        
        print(translateBtn.frame.size)
        
        
    }
    
    var autolayoutFlag = false
    override func layoutSubviews() {
        super.layoutSubviews()
        print("--------------------------[Memoview layoutSubview]--------------------------")

        if autolayoutFlag == false {
            print(translateBtn.frame.size)
            
            translateBtn.layer.cornerRadius = translateBtn.frame.width/2
            translateBtn.imageView?.layer.cornerRadius = translateBtn.imageView!.frame.width/2
            
            translateBtn.layer.masksToBounds = true
            
            
            
            albumBtn.layer.cornerRadius = albumBtn.frame.width/2
            cameraBtn.layer.cornerRadius = cameraBtn.frame.width/2
            
            autolayoutFlag = true
        }
    }
    
    
}
