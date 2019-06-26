//
//  GoogleCloudOCR.swift
//  SmartNote
//
//  Created by 행복한 개발자 on 26/06/2019.
//  Copyright © 2019 Alex Lee. All rights reserved.
//

import Foundation
import Alamofire

class GoogleCloudOCR {
    private let apiKey = "AIzaSyA1X0aSwkixFga8jgEU7NXNJZhFz2sFdd4"
    private var apiURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(apiKey)")!
    }
    
    func detect(from image: UIImage, completion: @escaping (OCRResult?) -> Void) {
        guard let base64Image = base64EncodeImage(image) else {
            print("Error while base64 encoding image")
            completion(nil)
            return
        }
        
        callGoogleVisionAPI(with: base64Image, completion: completion)
    }
    
    private func callGoogleVisionAPI(
        with base64EncodedImage: String,
        completion: @escaping (OCRResult?) -> Void) {
        
        let parameters: Parameters = [
            "requests": [
                [
                    "image": [
                        "content": base64EncodedImage
                    ],
                    "features": [
                        [
                            "type": "TEXT_DETECTION"
                        ]
                    ]
                ]
            ]
        ]
        let headers: HTTPHeaders = [
            "X-Ios-Bundle-Identifier": Bundle.main.bundleIdentifier ?? "",
        ]
        
        AF.request(
            apiURL,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers)
            .responseData { response in
                print("AF.request response Value: ", response)
                
                switch response.result {
                case .success(let value):
                    // Decode the JSON data into a `GoogleCloudOCRResponse` object.
                    print("AF.request Success: ", value)
                    
                    //                    guard let jasonObject = try? JSONSerialization.jsonObject(with: value) else {
                    //                        print("JSONSerialization convert failed")
                    //                        return
                    //                    }
                    //                    print("AF.request JsonObject: ", jasonObject)
                    
                    let ocrResponse = try? JSONDecoder().decode(GoogleCloudOCRResponse.self, from: value)
                    completion(ocrResponse?.responses[0])
                    
                case .failure(let error):
                    print("AF.request Failed: ", error)
                    completion(nil)
                    return
                }
                
                
                
        }
    }
    
    private func base64EncodeImage(_ image: UIImage) -> String? {
        return image.pngData()?.base64EncodedString(options: .endLineWithCarriageReturn)
    }
}
