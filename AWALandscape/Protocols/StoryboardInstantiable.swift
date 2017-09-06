//
//  StoryboardInstantiable.swift
//  gcb
//
//  Created by Naoto Yoneda on 2017/08/16.
//  Copyright © 2017年 MINTSU PLANNING CO., LTD. All rights reserved.
//

import UIKit


// MARK: - StoryboardInstantiable

protocol StoryboardInstantiable {

    static var storyboardName: String { get }
}


extension StoryboardInstantiable where Self: UIViewController {

    static func instantiate() -> Self {

        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as? Self

        if controller == nil {

            assert(false, "生成したいViewControllerと同じ名前のStorybaordが見つからないか、Initial ViewControllerに設定されていない可能性があります。")
        }

        return controller!
    }
}
