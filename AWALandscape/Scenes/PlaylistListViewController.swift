
//
//  PlaylistListViewController.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/08.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit
import MediaPlayer

protocol PlaylistListViewControllerDelegate: class {
    
    func switchPlayerViewController(_ oldViewController: UIViewController, sender: Int)
}

class PlaylistListViewController: UIViewController {
    
    let musicManager = MusicManager.shared
    let selectionFeedback = UISelectionFeedbackGenerator()
    let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
    let kItemSize = UIScreen.main.bounds.height / 2
    let centerThreshold: CGFloat = UIScreen.main.bounds.width / 4
    
    var length: CGFloat = 0.0
    weak var delegate: PlaylistListViewControllerDelegate!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        
        didSet {
            
            collectionView.register(PlaylistCollectionViewCell.self)
            collectionView.delegate = self
            collectionView.dataSource = self
            
            let verticalInset = (UIScreen.main.bounds.height - kItemSize) / 2
            let horizontalInset = (UIScreen.main.bounds.width - kItemSize / 2 * 3) / 2
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.itemSize = CGSize(width: kItemSize / 2 * 3, height: kItemSize)
            flowLayout.minimumLineSpacing = 20.0
            flowLayout.minimumInteritemSpacing = 20.0
            flowLayout.sectionInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset)
            flowLayout.scrollDirection = .horizontal
            collectionView.collectionViewLayout = flowLayout
            
            if let count = items?.count {
                
                length = (flowLayout.itemSize.width + 20.0) * CGFloat(count > 0 ? count - 1 : 0)
            }
        }
    }
    @IBOutlet weak var thumbView: UIView!
    @IBOutlet weak var scrollBarView: UIView! {
        
        didSet {
            
            scrollBarView.alpha = 0.0
        }
    }
    @IBOutlet weak var sliderConstraint: NSLayoutConstraint!
    @IBOutlet weak var playConstraint: NSLayoutConstraint!
    var animTimer: Timer!
    @IBOutlet weak var playHelperLabel: UILabel! {
        
        didSet {
            
            let font = UIFont.fontAwesome(ofSize: 30)
            let text = String.fontAwesomeIcon(name: .playCircle)
            playHelperLabel.text = text
            playHelperLabel.font = font
            animTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(animLabel), userInfo: nil, repeats: true)
            animTimer.fire()
        }
    }
    @IBOutlet weak var helperConstraint: NSLayoutConstraint! {
        
        didSet {
            
            helperConstraint.constant = -18
        }
    }

    var isTouching = false
    var selectorPosition = 0 {
        
        didSet {
            
            if oldValue != selectorPosition {
                
                selectionFeedback.selectionChanged()
            }
        }
    }
    var items: [MPMediaItemCollection]? {
        
        get {
            
            return musicManager.playlists
        }
    }
    var selectFlag: Bool = false {
        
        didSet {
            
            if oldValue != selectFlag && selectFlag {
                
                impactFeedback.impactOccurred()
            }
        }
    }

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    deinit {
        
        if animTimer.isValid {
            
            animTimer.invalidate()
        }
    }
    
    func animLabel() {
        
        UIView.animate(withDuration: 1.0, animations: {
            
            self.playHelperLabel.alpha = 0.0
        }) { _ in
            
            UIView.animate(withDuration: 1.0, animations: {
                
                self.playHelperLabel.alpha = 1.0
            })
        }
    }
}

extension PlaylistListViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            
            return
        }
        
        if isInside(inView: thumbView, point: touch.location(in: view)) {
            
            isTouching = true
            helperConstraint.constant = 35
            UIView.animate(withDuration: 0.5, animations: {
                
                self.scrollBarView.alpha = 1.0
                self.playHelperLabel.layoutIfNeeded()
            })
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            
            return
        }
        
        if isTouching {
            
            playConstraint.constant += touch.location(in: view).x - touch.previousLocation(in: view).x
            if playConstraint.constant > 0 {
                
                updateSliderConstraint(touch)
                playConstraint.constant = 0
                selectFlag = false
            } else if playConstraint.constant > -20.0 {
                
                updateSliderConstraint(touch)
                selectFlag = false
            } else if playConstraint.constant < -40.0 {
                
                isTouching = false
                selectFlag = false
                delegate.switchPlayerViewController(self, sender: selectorPosition)
            } else {
                
                let rate = playConstraint.constant / -70.0
                if rate > 0.5 {
                    
                    selectFlag = true
                } else {
                    
                    selectFlag = false
                }
            }

        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        playConstraint.constant = 0.0
        selectFlag = false
        isTouching = false
        helperConstraint.constant = -18
        UIView.animate(withDuration: 0.5, animations: {
            
            self.scrollBarView.alpha = 0.0
            self.playHelperLabel.layoutIfNeeded()
        })
    }
    
    func updateSliderConstraint(_ touch: UITouch) {
        
        sliderConstraint.constant += touch.location(in: view).y - touch.previousLocation(in: view).y
        if sliderConstraint.constant < 0 {
            
            sliderConstraint.constant = 0
        } else if sliderConstraint.constant > scrollBarView.frame.height - thumbView.frame.height {
            
            sliderConstraint.constant = scrollBarView.frame.height - thumbView.frame.height
        }
        setPosition()
    }
    
    private func isInside(inView: UIView, point: CGPoint) -> Bool {
        
        return point.x >= inView.frame.origin.x - 10.0 && point.y >= inView.frame.origin.y - 10.0 &&
            point.x <= inView.frame.origin.x + inView.frame.width + 10.0 &&
            point.y <= inView.frame.origin.y + inView.frame.height + 10.0
    }
    
    private func setPosition() {
        
        let unit = (scrollBarView.frame.height - thumbView.frame.height)  / CGFloat(items!.count > 0 ? items!.count - 1 : 0)
        
        var judge = -unit / 2
        for i in 0 ..< items!.count {
            
            if judge <= sliderConstraint.constant && sliderConstraint.constant < judge + unit {
                
                selectorPosition = i
            }
            judge += unit
        }
        
        collectionView.contentOffset = CGPoint(x: length * sliderConstraint.constant / (scrollBarView.frame.height - thumbView.frame.height), y: collectionView.contentOffset.y)
    }

}

extension PlaylistListViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return musicManager.playlists?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistCollectionViewCell.defaultReuseIdentifier, for: indexPath) as! PlaylistCollectionViewCell
        cell.currentAlbum = indexPath.row
        cell.miniTitleLabel.isHidden = true
        return cell
    }
}

extension PlaylistListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        delegate.switchPlayerViewController(self, sender: indexPath.row)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        animateCell(scrollView)
        UIView.animate(withDuration: 0.5, animations: {
            
            self.scrollBarView.alpha = 1.0
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        sliderConstraint.constant = (scrollBarView.frame.height - thumbView.frame.height) * scrollView.contentOffset.x / length
        let unit = (scrollBarView.frame.height - thumbView.frame.height)  / CGFloat(items!.count > 0 ? items!.count - 1 : 0)
        
        var judge = -unit / 2
        for i in 0 ..< items!.count {
            
            if judge <= sliderConstraint.constant && sliderConstraint.constant < judge + unit {
                
                selectorPosition = i
            }
            judge += unit
        }
        animateCell(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if !isTouching {
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.scrollBarView.alpha = 0.0
            })
        }
    }
    
    func animateCell(_ scrollView: UIScrollView) {
        
        let cells = collectionView.visibleCells
        for cell in cells {
            
            let centerX = cell.center.x - scrollView.contentOffset.x
            let ratio = 1.0 - fabs(view.bounds.width / 2 - centerX) / centerThreshold
            if ratio > 0.0 {
                
                cell.transform = CGAffineTransform(scaleX: 1.0 + 0.5 * ratio, y: 1.0 + 0.5 * ratio)
            } else {
                
                cell.transform = .identity
            }
            if collectionView.indexPath(for: cell)!.row == selectorPosition {
                
                collectionView.bringSubview(toFront: cell)
            }
        }
    }
}

extension PlaylistListViewController: StoryboardInstantiable {
    
    static var storyboardName: String {
        
        return String(describing: self)
    }
}