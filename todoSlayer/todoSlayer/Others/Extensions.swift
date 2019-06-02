//
//  Extensions.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 09/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import UIKit

extension NSObject {
    class var name: String {
        return String(describing: self)
    }
}

extension UIButton {
    func enable() {
        self.isEnabled = true
        self.alpha = 1
    }
    
    func disable() {
        self.isEnabled = false
        self.alpha = 0.5
    }
}
