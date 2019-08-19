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
    enum MemoState {
        case empty
        case editing
        case saved
    }
    
    // MARK: - UI Properties
    let textContainerView = UIView()
    let textView = UITextView()
    let textViewPlaceHolderLabel = UILabel()
    
    let saveInfoContainerView = UIView()
    let saveInfoImageView = UIImageView()
    let saveInfoLabel = UILabel()
    
    let bottomSeparateLineView = UIView()
    let albumBtn = UIButton()
    let cameraBtn = UIButton()
    
    let albumLabel = UILabel()
    let cameraLabel = UILabel()
    let translateBtn = UIButton()
    
    let translateContainerView = UIView()
    let translateFromBtn = UIButton()
    let translateToBtn = UIButton()
    let translateNoticeView = UIView()
    let translateNoticeLabel = UILabel()
    
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
    
    var memoState: MemoState = .empty {
        didSet {
            switch memoState {
            case .empty, .editing:
                saveInfoImageView.image = UIImage(named: "saveUnChecked")
                saveInfoLabel.text = "저장되지않음"
            case .saved:
                saveInfoImageView.image = UIImage(named: "saveChecked")
                saveInfoLabel.text = "저장됨"
            }
        }
    }
    
    var dropDownTransFrom = DropDown()
    var dropDownTransTo = DropDown()
    
    let notiCenter = NotificationCenter.default
    
    let translateLanguageArray = ["Korean", "English", "Chinese", "Japanese"]
    
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
        let buttonSpacing: CGFloat = 90
        let buttonSize: CGFloat = 80
        
        // =================================== 하단 버튼 ===================================
        self.addSubview(bottomSeparateLineView)
        bottomSeparateLineView.translatesAutoresizingMaskIntoConstraints = false
        bottomSeparateLineView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1).isActive = true
        //        bottomBackgroundUIView.topAnchor.constraint(equalTo: translateContainerView.bottomAnchor, constant: 30).isActive = true
        bottomSeparateLineView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -UIScreen.main.bounds.height * 0.12).isActive = true
        bottomSeparateLineView.heightAnchor.constraint(equalToConstant: 1.5).isActive = true
        
        self.addSubview(albumBtn)
        albumBtn.translatesAutoresizingMaskIntoConstraints = false
        albumBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: -buttonSpacing).isActive = true
        albumBtn.centerYAnchor.constraint(equalTo: bottomSeparateLineView.bottomAnchor, constant: 30).isActive = true
        albumBtn.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        albumBtn.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        
        self.addSubview(albumLabel)
        albumLabel.translatesAutoresizingMaskIntoConstraints = false
        albumLabel.centerXAnchor.constraint(equalTo: albumBtn.centerXAnchor, constant: 0).isActive = true
        albumLabel.bottomAnchor.constraint(equalTo: albumBtn.bottomAnchor, constant: -3).isActive = true
        
        self.addSubview(cameraBtn)
        cameraBtn.translatesAutoresizingMaskIntoConstraints = false
        cameraBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: buttonSpacing).isActive = true
        cameraBtn.centerYAnchor.constraint(equalTo: albumBtn.centerYAnchor).isActive = true
        cameraBtn.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        cameraBtn.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        
        self.addSubview(cameraLabel)
        cameraLabel.translatesAutoresizingMaskIntoConstraints = false
        cameraLabel.centerXAnchor.constraint(equalTo: cameraBtn.centerXAnchor, constant: 0).isActive = true
        cameraLabel.bottomAnchor.constraint(equalTo: cameraBtn.bottomAnchor, constant: -3).isActive = true
        
        // =================================== TranslateContainerView ===================================
        self.addSubview(translateContainerView)
        translateContainerView.translatesAutoresizingMaskIntoConstraints = false
        translateContainerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        translateContainerView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.90).isActive = true
        translateContainerView.bottomAnchor.constraint(equalTo: bottomSeparateLineView.topAnchor, constant: -15).isActive = true
//        translateContainerView.topAnchor.constraint(equalTo: textContainerView.bottomAnchor, constant: 35).isActive = true
        translateContainerView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        translateContainerView.addSubview(translateBtn)
        translateBtn.translatesAutoresizingMaskIntoConstraints = false
        translateBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        translateBtn.centerYAnchor.constraint(equalTo: translateContainerView.centerYAnchor, constant: 0).isActive = true
        translateBtn.heightAnchor.constraint(equalTo: translateContainerView.heightAnchor, multiplier: 0.6).isActive = true
        translateBtn.widthAnchor.constraint(equalTo: translateBtn.heightAnchor, multiplier: 1).isActive = true
        
        translateContainerView.addSubview(translateFromBtn)
        translateFromBtn.translatesAutoresizingMaskIntoConstraints = false
        translateFromBtn.centerXAnchor.constraint(equalTo: translateContainerView.centerXAnchor, constant: -90).isActive = true
        translateFromBtn.centerYAnchor.constraint(equalTo: translateContainerView.centerYAnchor).isActive = true
        translateFromBtn.widthAnchor.constraint(equalToConstant: 70).isActive = true
        translateFromBtn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        translateContainerView.addSubview(translateToBtn)
        translateToBtn.translatesAutoresizingMaskIntoConstraints = false
        translateToBtn.centerXAnchor.constraint(equalTo: translateContainerView.centerXAnchor, constant: 90).isActive = true
        translateToBtn.centerYAnchor.constraint(equalTo: translateContainerView.centerYAnchor).isActive = true
        translateToBtn.widthAnchor.constraint(equalToConstant: 70).isActive = true
        translateToBtn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        self.addSubview(translateNoticeView)
        translateNoticeView.snp.makeConstraints { (make) in
            make.leading.equalTo(translateContainerView.snp.leading)
            make.bottom.equalTo(translateContainerView.snp.top).offset(10)
            make.width.equalTo(70)
            make.height.equalTo(30)
        }
        
        translateNoticeView.addSubview(translateNoticeLabel)
        translateNoticeLabel.snp.makeConstraints { (make) in
//            make.leading.equalTo(5)
            make.centerX.equalToSuperview()
            make.top.equalTo(3)
        }
        
        self.sendSubviewToBack(translateNoticeView)
        
        // =================================== TextContainerView ===================================
        let margin: CGFloat = 10
        self.addSubview(textContainerView)
        textContainerView.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.topAnchor.constraint(equalTo: self.topAnchor, constant: margin).isActive = true
        textContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: margin).isActive = true
        textContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -margin).isActive = true
        textContainerView.bottomAnchor.constraint(equalTo: translateNoticeView.topAnchor, constant: -10).isActive = true
//        textContainerView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.62).isActive = true
        
        textContainerView.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.topAnchor.constraint(equalTo: textContainerView.topAnchor, constant: margin).isActive = true
        textView.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor, constant: margin).isActive = true
        textView.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -margin).isActive = true
        textView.bottomAnchor.constraint(equalTo: self.textContainerView.bottomAnchor, constant: -margin).isActive = true
        
        textContainerView.addSubview(textViewPlaceHolderLabel)
        textViewPlaceHolderLabel.translatesAutoresizingMaskIntoConstraints = false
        textViewPlaceHolderLabel.centerXAnchor.constraint(equalTo: textView.centerXAnchor).isActive = true
        textViewPlaceHolderLabel.centerYAnchor.constraint(equalTo: textView.centerYAnchor).isActive = true
        
        // 저장된 정보 ContainerView
        textContainerView.addSubview(saveInfoContainerView)
        saveInfoContainerView.translatesAutoresizingMaskIntoConstraints = false
        saveInfoContainerView.topAnchor.constraint(equalTo: textContainerView.topAnchor, constant: 5).isActive = true
        saveInfoContainerView.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor, constant: -8).isActive = true
        saveInfoContainerView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        saveInfoContainerView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        saveInfoContainerView.addSubview(saveInfoLabel)
        saveInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        saveInfoLabel.trailingAnchor.constraint(equalTo: saveInfoContainerView.trailingAnchor, constant: 0).isActive = true
        saveInfoLabel.topAnchor.constraint(equalTo: saveInfoContainerView.topAnchor).isActive = true
        saveInfoLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        let cons = saveInfoLabel.widthAnchor.constraint(equalToConstant: 60)
        cons.priority = .defaultLow
        cons.isActive = true
        saveInfoLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        saveInfoContainerView.addSubview(saveInfoImageView)
        saveInfoImageView.translatesAutoresizingMaskIntoConstraints = false
        saveInfoImageView.trailingAnchor.constraint(equalTo: saveInfoLabel.leadingAnchor, constant: 0).isActive = true
        saveInfoImageView.topAnchor.constraint(equalTo: saveInfoContainerView.topAnchor).isActive = true
        saveInfoImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        saveInfoImageView.heightAnchor.constraint(equalTo: saveInfoImageView.widthAnchor, multiplier: 1).isActive = true
    }
    
    private func configureViewsOptions() {
        print("--------------------------[MemoView configureViewOptions]--------------------------")
        textContainerView.backgroundColor = #colorLiteral(red: 0.9764593244, green: 0.9706541896, blue: 0.9809214473, alpha: 1)
        textContainerView.layer.cornerRadius = 10
        textContainerView.layer.shadowColor = UIColor.gray.cgColor
        textContainerView.layer.shadowOpacity = 0.8
        textContainerView.layer.shadowOffset = CGSize(width: 2, height: 2)
        textContainerView.layer.shadowRadius = 0.2
        
        textView.backgroundColor = .clear
        textView.textAlignment = .left
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.delegate = self
        
        textViewPlaceHolderLabel.font = UIFont.systemFont(ofSize: 15)
        textViewPlaceHolderLabel.text = "Detected text can be edited here"
        textViewPlaceHolderLabel.textColor = #colorLiteral(red: 0.5864446886, green: 0.6151993181, blue: 0.6221644987, alpha: 0.8590004281)
        
        saveInfoLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        saveInfoLabel.textColor = #colorLiteral(red: 0.6031692624, green: 0.5995866656, blue: 0.6059251428, alpha: 0.903119649)
        
        // =================================== 하단 버튼 ===================================
        bottomSeparateLineView.backgroundColor = UIColor(red:0.50, green:0.87, blue:0.92, alpha:1.0)
        
        let albumInset: CGFloat = 24
        albumBtn.setImage(UIImage(named: "AlbumSample3"), for: .normal)
        albumBtn.imageView?.contentMode = .scaleAspectFit
        albumBtn.imageEdgeInsets = .init(top: albumInset, left: albumInset, bottom: albumInset, right: albumInset)
        
        albumLabel.text = "Album"
        albumLabel.font = .systemFont(ofSize: 12, weight: .medium)
        albumLabel.textColor = UIColor(red:0.40, green:0.40, blue:0.40, alpha:1.0)
//        albumLabel.textColor = .black
        
        
        let cameraInset: CGFloat = 20
        cameraBtn.setImage(UIImage(named: "cameraSample3"), for: .normal)
        cameraBtn.imageView?.contentMode = .scaleAspectFit
        cameraBtn.imageEdgeInsets = UIEdgeInsets(top: cameraInset, left: cameraInset, bottom: cameraInset, right: cameraInset)
        
        cameraLabel.text = "Camera"
        cameraLabel.font = .systemFont(ofSize: 12, weight: .medium)
        cameraLabel.textColor = UIColor(red:0.40, green:0.40, blue:0.40, alpha:1.0)
//        cameraLabel.textColor = .black
        
        
        // =================================== TranslateContainerView ===================================
//        translateContainerView.backgroundColor = UIColor(red:0.00, green:0.67, blue:0.76, alpha:0.3)
//        translateContainerView.backgroundColor = UIColor(red:0.74, green:0.89, blue:0.92, alpha:1.0)
        translateContainerView.backgroundColor = UIColor(red:0.64, green:0.88, blue:0.92, alpha:1.0)
        translateContainerView.layer.cornerRadius = 5
        
        translateBtn.setImage(UIImage(named: "tranlsateIcon2"), for: .normal)
        translateBtn.addTarget(self, action: #selector(translateBtnDidTap(_:)), for: .touchUpInside)
//        translateBtn.backgroundColor = .white
        
        translateFromBtn.setTitle("Korean", for: .normal)
        translateFromBtn.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        translateFromBtn.setTitleColor(.black, for: .normal)
        translateFromBtn.tag = 0
        translateFromBtn.addTarget(self, action: #selector(translateDropDownBtnDidTap(_:)), for: .touchUpInside)
        
        translateToBtn.setTitle("English", for: .normal)
        translateToBtn.setTitleColor(.black, for: .normal)
        translateToBtn.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        //        translateToBtn.backgroundColor = .yellow
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
        
        translateNoticeView.backgroundColor = #colorLiteral(red: 0.9944962859, green: 0.5105027556, blue: 0.03178439289, alpha: 0.749411387)
        translateNoticeView.layer.cornerRadius = 5
        translateNoticeLabel.text = "Translate"
        translateNoticeLabel.textColor = .black
        translateNoticeLabel.font = .systemFont(ofSize: 10.5, weight: .semibold)
    }
    
    var autolayoutFlag = false
    override func layoutSubviews() {
        super.layoutSubviews()
        print("--------------------------[Memoview layoutSubview]--------------------------")
        if autolayoutFlag == false {
            print(translateBtn.frame.size)
            
//            albumBtn.layer.cornerRadius = albumBtn.frame.width/2
//            cameraBtn.layer.cornerRadius = cameraBtn.frame.width/2
            
            
//            translateFromBtn.layer.cornerRadius = 10
//            translateToBtn.layer.cornerRadius = 10
            
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
    
    func hideSaveInfoContainerView() {
        UIView.animate(withDuration: 0.5, animations: {
            self.saveInfoContainerView.layer.opacity = 0
        }) { (_) in
            self.saveInfoContainerView.isHidden = true
            self.memoState = .empty
        }
    }
    
    func showSaveInfoContainerView() {
        saveInfoContainerView.isHidden = false
        saveInfoContainerView.layer.opacity = 0
        
        UIView.animate(withDuration: 0.5, animations: {
            self.saveInfoContainerView.layer.opacity = 1
        })
    }
}

extension MemoView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("--------------------------[MemoView textView Did Begin Editing]--------------------------")
        textView.centerVertically()
        isTextViewHasText = true
        notiCenter.post(name: .memoTextViewEditingDidBegin, object: nil)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("--------------------------[MemoView textView Did End Editing]--------------------------")
        notiCenter.post(name: .memoTextViewEditingDidEnd, object: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print("--------------------------[MemoView TextView DidChange]--------------------------")
        textView.centerVertically()
        
        guard textView.hasText else {
            // 텍스트가 없어지면 saveInfoContainerView를 숨김
            hideSaveInfoContainerView()
            return
        }
        
        if memoState == .empty {
            showSaveInfoContainerView()
        }
        memoState = .editing
    }
}
