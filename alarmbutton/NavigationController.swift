//
//  NavigationController.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 22/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import UIKit

class NavigationController : UINavigationController {
    
    override func viewDidLoad() {
        navigationBar.barTintColor = UIColor.primaryColor
        navigationBar.isTranslucent = false
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBar.tintColor = .white
    }
    
}
