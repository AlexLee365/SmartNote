//
//  MemoView.swift
//  SmartNote
//
//  Created by 행복한 개발자 on 26/06/2019.
//  Copyright © 2019 Alex Lee. All rights reserved.
//

import UIKit
import DropDown
import Alamofire

class MemoView: UIView {
    
    // MARK: - UI Properties
    let textView = UITextView()
    let textViewPlaceHolderLabel = UILabel()
    
    let albumBtn = UIButton()
    let cameraBtn = UIButton()
    let translateBtn = UIButton()
    
    
    let translateContainerView = UIView()
    let translateFromBtn = UIButton()
    let translateToBtn = UIButton()
    
    
    // MARK: - Properties
    var isTextViewHasText = false {
        didSet {
            switch isTextViewHasText {
            case true:
                UIView.animate(withDuration: 0.5, animations: {
                    self.textViewPlaceHolderLabel.transform = CGAffineTransform(translationX: 0, y: -20)
                    self.textViewPlaceHolderLabel.layer.opacity = 0
                }) { _ in
                    self.textViewPlaceHolderLabel.isHidden = true
                }
            case false:
                self.textViewPlaceHolderLabel.isHidden = false
                UIView.animate(withDuration: 0.5, animations: {
                    self.textViewPlaceHolderLabel.transform = CGAffineTransform.identity
                    self.textViewPlaceHolderLabel.layer.opacity = 1
                })
            }
        }
    }
    
    var dropDownTransFrom = DropDown()
    var dropDownTransTo = DropDown()
    
    let translateLanguageArray = ["Korean", "English", "Chinese", "Japanese"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("--------------------------[MemoView init]--------------------------")
        
        setAutoLayout()
        configureViewsOptions()
        
    }
    
    let notiCenter = NotificationCenter.default
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    private func setAutoLayout() {
        print("--------------------------[MemoView setAutoLayout]--------------------------")
        
        let buttonSpacing = UIScreen.main.bounds.width/5
        let buttonSize: CGFloat = 80
        
        self.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        textView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -300).isActive = true
        
        self.addSubview(textViewPlaceHolderLabel)
        textViewPlaceHolderLabel.translatesAutoresizingMaskIntoConstraints = false
        textViewPlaceHolderLabel.centerXAnchor.constraint(equalTo: textView.centerXAnchor).isActive = true
        textViewPlaceHolderLabel.centerYAnchor.constraint(equalTo: textView.centerYAnchor).isActive = true
        
        
        
        // =================================== ===================================
        
        
        self.addSubview(albumBtn)
        albumBtn.translatesAutoresizingMaskIntoConstraints = false
        albumBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: -buttonSpacing).isActive = true
        albumBtn.centerYAnchor.constraint(equalTo: self.bottomAnchor, constant: -80).isActive = true
        albumBtn.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        albumBtn.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        
        self.addSubview(cameraBtn)
        cameraBtn.translatesAutoresizingMaskIntoConstraints = false
        cameraBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: buttonSpacing).isActive = true
        cameraBtn.centerYAnchor.constraint(equalTo: albumBtn.centerYAnchor).isActive = true
        cameraBtn.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        cameraBtn.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        
        // =================================== translateContainerView ===================================
        self.addSubview(translateContainerView)
        translateContainerView.translatesAutoresizingMaskIntoConstraints = false
        translateContainerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        translateContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -180).isActive = true
        translateContainerView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.85).isActive = true
        translateContainerView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        translateContainerView.addSubview(translateBtn)
        translateBtn.translatesAutoresizingMaskIntoConstraints = false
        translateBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        translateBtn.centerYAnchor.constraint(equalTo: translateContainerView.centerYAnchor, constant: 0).isActive = true
        translateBtn.widthAnchor.constraint(equalToConstant: buttonSize+20).isActive = true
        translateBtn.heightAnchor.constraint(equalToConstant: buttonSize+20).isActive = true
        
        translateContainerView.addSubview(translateFromBtn)
        translateFromBtn.translatesAutoresizingMaskIntoConstraints = false
        translateFromBtn.centerXAnchor.constraint(equalTo: translateContainerView.centerXAnchor, constant: -80).isActive = true
        translateFromBtn.centerYAnchor.constraint(equalTo: translateContainerView.centerYAnchor).isActive = true
        translateFromBtn.widthAnchor.constraint(equalToConstant: 70).isActive = true
        translateFromBtn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        translateContainerView.addSubview(translateToBtn)
        translateToBtn.translatesAutoresizingMaskIntoConstraints = false
        translateToBtn.centerXAnchor.constraint(equalTo: translateContainerView.centerXAnchor, constant: 80).isActive = true
        translateToBtn.centerYAnchor.constraint(equalTo: translateContainerView.centerYAnchor).isActive = true
        translateToBtn.widthAnchor.constraint(equalToConstant: 70).isActive = true
        translateToBtn.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    private func configureViewsOptions() {
        print("--------------------------[MemoView configureViewOptions]--------------------------")
        textView.backgroundColor = .white
        textView.textAlignment = .left
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.delegate = self
        
        textViewPlaceHolderLabel.font = UIFont.systemFont(ofSize: 15)
        textViewPlaceHolderLabel.text = "Detected text can be edited here"
        textViewPlaceHolderLabel.textColor = #colorLiteral(red: 0.5864446886, green: 0.6151993181, blue: 0.6221644987, alpha: 0.8590004281)
        textView.backgroundColor = .cyan
        
        
        albumBtn.backgroundColor = .blue
        albumBtn.setTitle("Album", for: .normal)
        albumBtn.setTitleColor(.black, for: .normal)
        albumBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        
        cameraBtn.backgroundColor = .cyan
        cameraBtn.setTitle("Camera", for: .normal)
        cameraBtn.setTitleColor(.black, for: .normal)
        cameraBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        
        
        translateContainerView.backgroundColor = #colorLiteral(red: 0.7473826142, green: 0.7473826142, blue: 0.7473826142, alpha: 0.4949700342)
        
        translateBtn.setImage(UIImage(named: "transIcon"), for: .normal)
        translateBtn.addTarget(self, action: #selector(translateBtnDidTap(_:)), for: .touchUpInside)
        
        translateFromBtn.setTitle("Korean", for: .normal)
        translateFromBtn.titleLabel?.font = .systemFont(ofSize: 13)
        translateFromBtn.setTitleColor(.black, for: .normal)
        translateFromBtn.backgroundColor = .yellow
        translateFromBtn.tag = 0
        translateFromBtn.addTarget(self, action: #selector(translateDropDownBtnDidTap(_:)), for: .touchUpInside)
        
        translateToBtn.setTitle("English", for: .normal)
        translateToBtn.setTitleColor(.black, for: .normal)
        translateToBtn.titleLabel?.font = .systemFont(ofSize: 13)
        translateToBtn.backgroundColor = .yellow
        translateToBtn.tag = 1
        translateToBtn.addTarget(self, action: #selector(translateDropDownBtnDidTap(_:)), for: .touchUpInside)
        
        
        
        dropDownTransFrom.anchorView = translateFromBtn
        dropDownTransFrom.bottomOffset = CGPoint(x: 0, y:(dropDownTransFrom.anchorView?.plainView.bounds.height)!)
        dropDownTransFrom.backgroundColor = .white
        dropDownTransFrom.dataSource = translateLanguageArray
        dropDownTransFrom.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            
            self.translateFromBtn.setTitle(item, for: .normal)
        }
        
        dropDownTransTo.anchorView = translateToBtn
        dropDownTransTo.bottomOffset = CGPoint(x: 0, y:(dropDownTransTo.anchorView?.plainView.bounds.height)!)
        dropDownTransTo.backgroundColor = .white
        dropDownTransTo.dataSource = translateLanguageArray
        dropDownTransTo.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            
            self.translateToBtn.setTitle(item, for: .normal)
        }
    }
    
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        print("--------------------------[MemoView didMoveToSuperView]--------------------------")
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
            
            translateContainerView.layer.cornerRadius = 5
            translateFromBtn.layer.cornerRadius = 10
            translateToBtn.layer.cornerRadius = 10
            
            autolayoutFlag = true
        }
    }
    
    @objc func translateDropDownBtnDidTap(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            dropDownTransFrom.show()
        case 1:
            dropDownTransTo.show()
        default : break
        }
        
    }
    
    @objc func translateBtnDidTap(_ sender: UIButton) {
        let queryValue = textView.text ?? ""
        
        func returnLanguageString(_ buttonTitle: String) -> String {
            var returnString = ""
            
            switch buttonTitle {
            case translateLanguageArray[0]:
                returnString = "kr"
            case translateLanguageArray[1]:
                returnString = "en"
            case translateLanguageArray[2]:
                returnString = "cn"
            case translateLanguageArray[3]:
                returnString = "jp"
            default: break
            }
            return returnString
        }
        
        let languageTranslateFrom = returnLanguageString(translateFromBtn.titleLabel?.text ?? "")
        let languageTranslateTo = returnLanguageString(translateToBtn.titleLabel?.text ?? "")
        
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
                
                
                self.textView.text = text
                
                self.notiCenter.post(Notification(name: Notification.Name("textViewEditingEnd")))
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
}

extension MemoView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("--------------------------[MemoView textView Did Begin Editing]--------------------------")
        textView.centerVertically()
        isTextViewHasText = true
        notiCenter.post(Notification(name: Notification.Name("textViewEditing")))
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("--------------------------[MemoView textView Did End Editing]--------------------------")
        if textView.text.isEmpty {
            isTextViewHasText = false
            notiCenter.post(Notification(name: Notification.Name("textViewEditingEndButEmpty")))
        } else {
            notiCenter.post(Notification(name: Notification.Name("textViewEditingEnd")))
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print("--------------------------[MemoView TextView DidChange]--------------------------")
        textView.centerVertically()
    }
    
   
   
}
