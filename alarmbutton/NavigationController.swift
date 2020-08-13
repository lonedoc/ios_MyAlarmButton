//
//  NavigationController.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 22/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import UIKit

class NavigationController : UINavigationController {
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        navigationBar.barTintColor = UIColor.primaryColor
        navigationBar.isTranslucent = false
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBar.tintColor = .white
    }
    
}
