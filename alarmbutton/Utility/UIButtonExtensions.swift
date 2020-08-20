//
//  UIButtonExtensions.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 04/06/2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import UIKit

extension UIButton {

    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        clipsToBounds = true

        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))

        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))

            let colorImage = UIGraphicsGetImageFromCurrentImageContext()

            UIGraphicsEndImageContext()

            setBackgroundImage(colorImage, for: state)
        }
    }

}
