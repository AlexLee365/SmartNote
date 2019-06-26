//
//  MemoViewController.swift
//  SmartNote
//
//  Created by 행복한 개발자 on 26/06/2019.
//  Copyright © 2019 Alex Lee. All rights reserved.
//

import UIKit

class MemoViewController: UIViewController {
    
    let memoView = MemoView()
    
    override func loadView() {
        view = memoView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setAutoLayout() {
        let safeGuide = view.safeAreaLayoutGuide
        
        
    }
    

}
