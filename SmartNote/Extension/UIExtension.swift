//
//  UIExtension.swift
//  SmartNote
//
//  Created by 행복한 개발자 on 26/06/2019.
//  Copyright © 2019 Alex Lee. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let memoTextViewEditingDidBegin = Notification.Name("MemoTextViewEditingDidBegin")
    static let memoTextViewEditingDidEnd = Notification.Name("MemoTextViewEditingDidEnd")
}

extension UITextView {
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        self.contentOffset.y = -positiveTopOffset
    }
}

extension UIImage {
    func resize(to targetSize: CGSize) -> UIImage? {
        let image = self
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle.
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height + 1)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func cropImage(viewFrameToScaleFromImage: CGRect) -> UIImage? {
        let image = self
        print("원본 이미지 사이즈: ",image.size)
        let scaledImageWidth = image.size.width
        let scaledImageHeight = image.size.width * (viewFrameToScaleFromImage.size.height / viewFrameToScaleFromImage.size.width)
        // 이미지의 넓이 * (카메라가 보여지는 뷰의 프레임의 비율 = 높이 / 넓이)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: scaledImageWidth, height: scaledImageHeight), true, 0.0)
        
        let upsideGap = (image.size.height - scaledImageHeight) / 2
        
        print("cropImageNotUsingCGImage: ", upsideGap)
        image.draw(at: CGPoint(x: 0, y: -upsideGap))
        
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return croppedImage
    }
}

