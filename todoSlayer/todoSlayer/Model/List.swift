//
//  List.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 08/12/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import UIKit

struct List: Hashable {
    let name: String
    let icon: UIImage? = UIImage(systemName: "tray.and.arrow.down")
    
    enum Section {
        case one
    }
}
