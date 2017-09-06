//
//  NibLoadable.swift
//  gcb
//
//  Created by Naoto Yoneda on 2017/08/16.
//  Copyright © 2017年 MINTSU PLANNING CO., LTD. All rights reserved.
//

import UIKit


// MARK: - NibLoadble

protocol NibLoadable: class {

    static var nibName: String { get }
}

extension NibLoadable where Self: UIView {

    static var nibName: String {

        return String(describing: self)
    }
}
