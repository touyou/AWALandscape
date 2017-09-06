//
//  Reusable.swift
//  gcb
//
//  Created by Naoto Yoneda on 2017/08/16.
//  Copyright © 2017年 MINTSU PLANNING CO., LTD. All rights reserved.
//

import UIKit


// MARK: - Reusable

protocol Reusable: class {

    static var defaultReuseIdentifier: String { get }
}

extension Reusable where Self: UIView {

    static var defaultReuseIdentifier: String {

        return String(describing: self)
    }
}
