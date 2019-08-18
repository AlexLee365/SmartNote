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
    
    var interactionController: UIPercentDrivenInteractiveTransition?

    override func viewDidLoad() {
        super.viewDidLoad()
        setAutoLayout()
        configureViewsOptions()
        addNotificationObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        memoView.textView.text = ""
        memoView.isTextViewHasText = false
        memoView.saveInfoContainerView.layer.opacity = 0
        memoView.isSaved = true
    }
    
    private func setAutoLayout() {
        let safeGuide = view.safeAreaLayoutGuide
        
        view.addSubview(memoView)
        memoView.translatesAutoresizingMaskIntoConstraints = false
        memoView.topAnchor.constraint(equalTo: safeGuide.topAnchor).isActive = true
        memoView.leadingAnchor.constraint(equalTo: safeGuide.leadingAnchor).isActive = true
        memoView.trailingAnchor.constraint(equalTo: safeGuide.trailingAnchor).isActive = true
        memoView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func configureViewsOptions() {
        let titleImageView = UIImageView(image: UIImage(named: "smartmemo_black"))
        titleImageView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleImageView
        
        memoView.cameraBtn.addTarget(self, action: #selector(cameraBtnDidTap(_:)), for: .touchUpInside)
        memoView.albumBtn.addTarget(self, action: #selector(albumBtnDidTap(_:)), for: .touchUpInside)

        navigationItem.rightBarButtonItem = defaultRightBarBtn
        
        let swipeFromRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(_:)))
        swipeFromRight.direction = .right
        view.addGestureRecognizer(swipeFromRight)
        let swipeFromLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(_:)))
        swipeFromLeft.direction = .left
        view.addGestureRecognizer(swipeFromLeft)
        
//        let panLeft = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
//        view.addGestureRecognizer(panLeft)
        
    }
    
//    @objc func handleGesture(_ gesture: UIPanGestureRecognizer) {
//        let translate = gesture.translation(in: gesture.view)
//        let percent   = translate.x / gesture.view!.bounds.size.width
//        guard percent >= 0 else {
//            print(percent)
//            let memoListVC = MemoListViewController()
//            navigationController?.pushViewController(memoListVC, animated: true)
//            return
//        }
//
//        if gesture.state == .began {
//            let cameraVC = CameraViewController()
//            interactionController = UIPercentDrivenInteractiveTransition()
//            cameraVC.customTransitionDelegate.interactionController = interactionController
//
//            present(cameraVC, animated: true)
////            show(cameraVC, sender: self)
//        } else if gesture.state == .changed {
//            print("🔵🔵🔵 : ", percent)
//
//            interactionController?.update(percent)
//            view.superview!.superview!.superview!.frame.origin.x = +(view.frame.size.width * percent)
//        } else if gesture.state == .ended || gesture.state == .cancelled {
//            let velocity = gesture.velocity(in: gesture.view)
//            if (percent > 0.5 && velocity.x == 0) || velocity.x > 0 {
//                interactionController?.finish()
//            } else {
//                interactionController?.cancel()
//            }
//            interactionController = nil
//        }
//    }
    
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
            
            memoView.isTextViewHasText = true
            
            memoView.textView.centerVertically()
            if let language = NSLinguisticTagger.dominantLanguage(for: self.memoView.textView.text) {
                print(language)
            } else {
                print("Unkown language")
            }

        case Notification.Name("textViewEditingEndButEmpty"):
            print("textViewEditingEndButEmpty")
            navigationItem.rightBarButtonItem = defaultRightBarBtn
            
            UIView.animate(withDuration: 0.5, animations: {
                self.memoView.saveInfoContainerView.layer.opacity = 0
            }) { (_) in
                self.memoView.saveInfoContainerView.isHidden = true
                self.memoView.isSaved = true
            }
            
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
            
            memoView.saveInfoContainerView.isHidden = false
            memoView.saveInfoContainerView.layer.opacity = 0
            UIView.animate(withDuration: 0.5, animations: {
                self.memoView.isSaved = true
                self.memoView.saveInfoContainerView.layer.opacity = 1
            })
            
            // =================================== ===================================
            let date = Date()
            let text = memoView.textView.text ?? ""
            
            let memoData = MemoData(date: date, text: text)
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MemoCoreData")
            
            
            do {
                print("🔵🔵🔵 저장버튼클릭 => CoreData검색: ", memoView.textView.text)
                let objects = try managedObjectContext.fetch(request) as! [NSManagedObject]
                
                guard objects.count > 0 else {
                    print("There's no objects")
                    let entityDescription = NSEntityDescription.entity(forEntityName: "MemoCoreData", in: managedObjectContext)
                    let memoCoreDataObject = MemoCoreData(entity: entityDescription!, insertInto: managedObjectContext)
                    saveCoreDataFromMemoData(coreData: memoCoreDataObject, memoData: memoData)
                    try managedObjectContext.save(); return }
                
                var dataAlreadyExist = false
                for nsManagedObject in objects {
                    guard let coreData = nsManagedObject as? MemoCoreData else { print("coreData convert Error"); return }
                    
                    
                    if coreData.text == memoView.textView.text! {    // 데이터가 이미 존재하면 (이전에 저장했기때문에)
                        print("Data Exist")
                        dataAlreadyExist = true
                        let alert = UIAlertController(title: "Message", message: "이미 저장된 메모입니다", preferredStyle: .alert)
                        let action1 = UIAlertAction(title: "OK", style: .default) { _ in }
                        
                        alert.addAction(action1)
                        present(alert, animated: true)
                        return
                    }
                }
                
                if dataAlreadyExist == false {  // 데이터가 존재하지않으면 현재 데이터 저장
                    print("Data Not Exist")
                    let entityDescription = NSEntityDescription.entity(forEntityName: "MemoCoreData", in: managedObjectContext)
                    let memoCoreDataObject = MemoCoreData(entity: entityDescription!, insertInto: managedObjectContext)
                    saveCoreDataFromMemoData(coreData: memoCoreDataObject, memoData: memoData)
                    try managedObjectContext.save()
                }
                
            } catch let error as NSError {
                print("‼️‼️‼️ : ", error.localizedDescription)
            }
            
            
            
        } else {    // 완료 버튼 클릭시
            memoView.textView.resignFirstResponder()
            memoView.textView.centerVertically()
        }
    }
    
    @objc func respondToSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        print("--------------------------[memoVC respondSwipeGesture]--------------------------")
        switch gesture.direction {
        case .left:
            let memoListVC = MemoListViewController()
            navigationController?.pushViewController(memoListVC, animated: true)
        case .right:
            
//
//            if UIImagePickerController.isSourceTypeAvailable(.camera) {
//                presentImagePickerController(withSourceType: .camera)
//            } else {
//                let alert = UIAlertController(title: "Camera Not Available", message: "A camera is not available. Please try picking an image from the image library instead.", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                present(alert, animated: true, completion: nil)
//            }
            let cameraVC = CameraViewController()
//            navigationController?.pushViewController(cameraVC, animated: true)
            let transition = CATransition()
            transition.duration = 0.15
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromLeft
            //        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
            
            
            //            transition.startProgress
            
//            navigationController?.view.layer.add(transition, forKey: kCATransition)
            view.window!.layer.add(transition, forKey: kCATransition)
            
            cameraVC.modalPresentationStyle = .overCurrentContext
            present(cameraVC, animated: false)
//            navigationController?.pushViewController(cameraVC, animated: false)
            
            
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
        
        if sourceType == .photoLibrary {
            present(controller, animated: true, completion: nil)
        } else {
//            let transition = CATransition()
//            transition.duration = 0.15
//            transition.type = CATransitionType.push
//            transition.subtype = CATransitionSubtype.fromLeft
//        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
//            view.window!.layer.add(transition, forKey: kCATransition)
            
            present(controller, animated: true, completion: nil)
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 카메라 또는 앨범에서 이미지를 불러옴
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
                
                var text = ""
                self.memoView.textView.text = ocrResult.annotations.first?.text
//                ocrResult.annotations.forEach{
//                    print("$$")
//                    text += $0.text
//                    text.removeLast()
//                    self.memoView.textView.text = text
//                    print(text)
//                }
                self.notiCenter.post(Notification(name: Notification.Name("textViewEditingEnd")))
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
}





















// MARK: - Test
// =================================== 카메라 Presentation Animation 기능 실험 ===================================
// Instagram 카메라 뷰로 넘길때 present방식을 구현하기 위함

class TransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    /// Interaction controller
    ///
    /// If gesture triggers transition, it will set will manage its own
    /// `UIPercentDrivenInteractiveTransition`, but it must set this
    /// reference to that interaction controller here, so that this
    /// knows whether it's interactive or not.
    
    weak var interactionController: UIPercentDrivenInteractiveTransition?
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return PullDownAnimationController(transitionType: .presenting)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PullDownAnimationController(transitionType: .dismissing)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
}


class PullDownAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum TransitionType {
        case presenting
        case dismissing
    }
    
    let transitionType: TransitionType
    
    init(transitionType: TransitionType) {
        self.transitionType = transitionType
        
        super.init()
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let inView   = transitionContext.containerView
        let toView   = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!
        
        var frame = inView.bounds
        
        switch transitionType {
        case .presenting:
            frame.origin.x = -frame.size.width
            toView.frame = frame
            
            inView.addSubview(toView)
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                toView.frame = inView.bounds
            }, completion: { finished in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        case .dismissing:
            toView.frame = frame
            inView.insertSubview(toView, belowSubview: fromView)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                frame.origin.x = -frame.size.width
                fromView.frame = frame
            }, completion: { finished in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
}


class PresentationController: UIPresentationController {
    override var shouldRemovePresentersView: Bool { return true }
}


class custom: UINavigationController {
    
}
