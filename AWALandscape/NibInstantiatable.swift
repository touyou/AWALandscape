//
//  NibInstantiatable.swift
//  gcb
//
//  Created by Naoto Yoneda on 2017/08/21.
//  Copyright © 2017年 MINTSU PLANNING CO., LTD. All rights reserved.
//

import UIKit

protocol NibInstantiatable: NibLoadable {
    
    static var nibName: String { get }
}

extension NibInstantiatable {
    
    static func instantiate() -> Self {
        
        return instantiateWithName(name: nibName)
    }
    
    static func instantiateWithOwner(owner: AnyObject?) -> Self {
        
        return instantiateWithName(name: self.nibName, owner: owner)
    }
    
    static func instantiateWithName(name: String, owner: AnyObject? = nil) -> Self {
        
        let nib = UINib(nibName: name, bundle: nil)
        guard let view = nib.instantiate(withOwner: owner, options: nil).first as? Self else {
            
            fatalError("failed to load \(name) nib file")
        }
        return view
    }
}
