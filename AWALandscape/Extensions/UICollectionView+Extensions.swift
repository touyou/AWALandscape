//
//  UICollectionView+Extensions.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/06.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit

// MARK: - Reuse Extension

extension UICollectionView {
    
    func register<T: UICollectionViewCell>(_: T.Type) where T: Reusable {
        
        self.register(T.self, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func register<T: UICollectionViewCell>(_: T.Type) where T: Reusable, T: NibLoadable {
        
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        
        self.register(nib, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T where T: Reusable {
        
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        
        return cell
    }
    
    
    func register<T: UICollectionReusableView>(_: T.Type, forSupplementaryViewOfKind kind: String) where T: Reusable {
        
        self.register(T.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func register<T: UICollectionReusableView>(_: T.Type, forSupplementaryViewOfKind kind: String) where T: Reusable, T: NibLoadable {
        
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        
        self.register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind elementKind: String, for indexPath: IndexPath) -> T where T: Reusable {
        
        guard let view = self.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            
            fatalError("Could not dequeue supplementary view with identifier: \(T.defaultReuseIdentifier)")
        }
        
        return view
    }
}
