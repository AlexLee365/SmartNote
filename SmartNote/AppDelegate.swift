//
//  AppDelegate.swift
//  SmartNote
//
//  Created by 행복한 개발자 on 25/06/2019.
//  Copyright © 2019 Alex Lee. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        
        let memoVC = MemoViewController()
        let navigateController = UINavigationController(rootViewController: memoVC)
        
        
        window?.rootViewController = navigateController
        window?.makeKeyAndVisible()
    
        return true
    }




}

