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
    var currentIndex: Int = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        vcArray = [
            storyboard?.instantiateViewController(withIdentifier: PlayerInfoViewController.storyboardName) as! PlayerInfoViewController,
            storyboard?.instantiateViewController(withIdentifier: PlayerLyricViewController.storyboardName) as! PlayerLyricViewController,
            storyboard?.instantiateViewController(withIdentifier: PlayerVideoViewController.storyboardName) as! PlayerVideoViewController
        ]
        setViewControllers([vcArray[0]], direction: .forward, animated: true, completion: nil)
        dataSource = self
        delegate = self
    }
    
    func prepare() {
        
        (vcArray[0] as! PlayerInfoViewController).prepare()
        (vcArray[1] as! PlayerLyricViewController).prepare()
        (vcArray[2] as! PlayerVideoViewController).prepare()
    }
}

extension PlayerContentPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
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
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let viewController = pageViewController.viewControllers?.first {
            
            if viewController is PlayerInfoViewController {
                
                currentIndex = 0
            } else if viewController is PlayerLyricViewController {
                
                currentIndex = 1
            } else {
                
                currentIndex = 2
            }
        }
    }
}

extension PlayerContentPageViewController {
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        
        return 3
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        
        return currentIndex
    }
}
