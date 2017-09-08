//
//  PlayerContentPageViewController.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/07.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit

class PlayerContentPageViewController: UIPageViewController {

    var vcArray = [UIViewController]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        vcArray = [
            storyboard?.instantiateViewController(withIdentifier: PlayerInfoViewController.storyboardName) as! PlayerInfoViewController,
            storyboard?.instantiateViewController(withIdentifier: PlayerLyricViewController.storyboardName) as! PlayerLyricViewController,
            storyboard?.instantiateViewController(withIdentifier: PlayerVideoViewController.storyboardName) as! PlayerVideoViewController
        ]
        setViewControllers([vcArray[0]], direction: .forward, animated: true, completion: nil)
        dataSource = self
    }
    
    func setUI() {
        
        (vcArray[0] as! PlayerInfoViewController).setUI()
        (vcArray[1] as! PlayerLyricViewController).setUI()
        (vcArray[2] as! PlayerVideoViewController).setUI()
    }
}

extension PlayerContentPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if viewController.isKind(of: PlayerVideoViewController.self) {
            
            return vcArray[1]
        } else if viewController.isKind(of: PlayerLyricViewController.self) {
            
            return vcArray[0]
        } else {
            
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if viewController.isKind(of: PlayerInfoViewController.self) {
            
            return vcArray[1]
        } else if viewController.isKind(of: PlayerLyricViewController.self) {
            
            return vcArray[2]
        } else {
            
            return nil
        }
    }
}

extension PlayerContentPageViewController {
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        
        return 3
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        
        return 0
    }
}
