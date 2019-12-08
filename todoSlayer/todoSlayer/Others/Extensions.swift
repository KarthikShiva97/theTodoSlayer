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

extension UIViewController {
    func addChildVC(_ childVC: UIViewController, shouldSetFrame: Bool = true, and: (()->())? = nil) {
        DispatchQueue.main.async {
            self.addChild(childVC)
            childVC.view.frame = shouldSetFrame ? self.view.frame : childVC.view.frame
            self.view.addSubview(childVC.view)
            childVC.didMove(toParent: self)
            and?()
        }
    }
    
    func removeChildVC(_ childVC: UIViewController,  and: (()->())? = nil) {
        DispatchQueue.main.async {
            childVC.willMove(toParent: nil)
            childVC.view.removeFromSuperview()
            childVC.removeFromParent()
            and?()
        }
    }
}

extension Encodable {
    var json: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        return json as? [String: Any]
    }
}
