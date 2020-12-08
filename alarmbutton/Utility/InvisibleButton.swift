//
//  InvisibleButton.swift
//  alarmbutton
//
//  Created by Rubeg NPO on 08.12.2020.
//  Copyright © 2020 Rubeg NPO. All rights reserved.
//

import Foundation
import UIKit

class InvisibleButton: UIButton {

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let newArea = CGRect(
            x: self.bounds.origin.x - 30,
            y: self.bounds.origin.y - 30,
            width: self.bounds.size.width + 60,
            height: self.bounds.size.height + 60
        )
        return newArea.contains(point)
    }

}
