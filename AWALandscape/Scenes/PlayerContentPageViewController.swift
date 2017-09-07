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
    var infoModel = InfomationModel() {
        
        didSet {
            
            if vcArray.count == 3 {
                
                
            }
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        vcArray = [
            storyboard?.instantiateViewController(withIdentifier: "InfoViewController") as! PlayerInfoViewController,
            storyboard?.instantiateViewController(withIdentifier: "LyricViewController") as! PlayerLyricViewController,
            storyboard?.instantiateViewController(withIdentifier: "VideoViewController") as! PlayerVideoViewController
        ]
        setViewControllers([vcArray[0]], direction: .forward, animated: true, completion: nil)
        dataSource = self
    }
}

extension PlayerContentPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if viewController.isKind(of: PlayerVideoViewController.self) {
            
            return vcArray[1]
        } else if viewController.isKind(of: PlayerLyricViewController.self) {
            
            return vcArray[0]
        } else {
            
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if viewController.isKind(of: PlayerInfoViewController.self) {
            
            return vcArray[1]
        } else if viewController.isKind(of: PlayerLyricViewController.self) {
            
            return vcArray[2]
        } else {
            
            return nil
        }
    }
}
