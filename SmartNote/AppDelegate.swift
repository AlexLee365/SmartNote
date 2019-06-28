//
//  AppDelegate.swift
//  SmartNote
//
//  Created by 행복한 개발자 on 25/06/2019.
//  Copyright © 2019 Alex Lee. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MemoData")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        
        let memoVC = MemoViewController()
        let navigateController = UINavigationController(rootViewController: memoVC)
        
       
        navigateController.navigationBar.barTintColor = UIColor(red:0.50, green:0.87, blue:0.92, alpha:1.0)
        
        window?.rootViewController = navigateController
        window?.makeKeyAndVisible()
        
    
        return true
    }




}

