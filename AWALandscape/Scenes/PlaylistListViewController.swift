
//
//  PlaylistListViewController.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/08.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit
import MediaPlayer
import DZNEmptyDataSet

// MARK: - Protocol

protocol PlaylistListViewControllerDelegate: class {
    
    func switchPlayerViewController(_ oldViewController: UIViewController, sender: Int)
    func hideMasterView()
    func showMasterView()
}

class PlaylistListViewController: UIViewController {
    
    // MARK: - Property
    // MARK: Outlet
    
    @IBOutlet weak var collectionView: UICollectionView! {
        
        didSet {
            
            collectionView.register(PlaylistCollectionViewCell.self)
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.emptyDataSetSource = self
            collectionView.emptyDataSetDelegate = self
            
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
                length = length == 0 ? 1 : length
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
    @IBOutlet weak var playHelperLabel: UILabel! {
        
        didSet {
            
            let font = UIFont.fontAwesome(ofSize: 33)
            let text = String.fontAwesomeIcon(name: .playCircle)
            playHelperLabel.text = text
            playHelperLabel.font = font
            playHelperLabel.textColor = UIColor.AWA.awaOrange
            animTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(animLabel), userInfo: nil, repeats: true)
            animTimer.fire()
        }
    }
    @IBOutlet weak var helperConstraint: NSLayoutConstraint! {
        
        didSet {
            
            helperConstraint.constant = -18
        }
    }
    
    // MARK: Constant
    
    let musicManager = MusicManager.shared
    let selectionFeedback: Any? = {
        
        if #available(iOS 10.0, *) {
            
            return UISelectionFeedbackGenerator()
        } else {
            
            return nil
        }
    }()
    let impactFeedback: Any? = {
        
        if #available(iOS 10.0, *) {
            
            return UIImpactFeedbackGenerator(style: .heavy)
        } else {
            
            return nil
        }
    }()
    let kItemSize = UIScreen.main.bounds.height / 2
    let centerThreshold: CGFloat = UIScreen.main.bounds.width / 4
    
    // MARK: Variable
    
    var length: CGFloat = 1.0
    weak var delegate: PlaylistListViewControllerDelegate!
    var isTouching = false
    var selectorPosition = 0 {
        
        didSet {
            
            if oldValue != selectorPosition {
                
                if #available(iOS 10.0, *), let generator = selectionFeedback as? UISelectionFeedbackGenerator {
                
                    generator.selectionChanged()
                }
                collectionView.reloadData()
            }
        }
    }
    var items: [TYMediaItemCollection]? {
        
        get {
            
            return musicManager.playlists
        }
    }
    var selectFlag: Bool = false {
        
        didSet {
            
            if oldValue != selectFlag && selectFlag {
                
                if #available(iOS 10.0, *), let generator = impactFeedback as? UIImpactFeedbackGenerator {
                    
                    generator.impactOccurred()
                }
            }
        }
    }
    var animTimer: Timer!
    var isActive = true
    var animateView: UIView!
    var helperTimer: Timer!
    var timerCount = 0
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        musicManager.addObserve(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        animateView = UIView()
        animateView.backgroundColor = UIColor(displayP3Red: 255, green: 255, blue: 255, alpha: 0.7)
        animateView.frame = thumbView.bounds
        animateView.center = thumbView.center
        animateView.cornerRadius = animateView.bounds.width / 2
        view.insertSubview(animateView, belowSubview: thumbView)
    }
    
    deinit {
        
        if animTimer.isValid {
            
            animTimer.invalidate()
        }
        if helperTimer != nil && helperTimer.isValid {
            
            helperTimer.invalidate()
        }
        musicManager.removeObserve(self)
    }
    
    // MARK: - Timer
    
    func animLabel() {
        
        UIView.animate(withDuration: 1.0, animations: {
            
            self.playHelperLabel.alpha = 0.2
        }) { _ in
            
            UIView.animate(withDuration: 1.0, animations: {
                
                self.playHelperLabel.alpha = 1.0
            })
        }
    }
    
    func helperTimerExec() {
        
        if timerCount < 2 {
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.15) {
                
                UIView.animate(withDuration: 0.7, animations: {
                    
                    self.animateView.center.x = self.playHelperLabel.center.x + 5
                }) { _ in
                    
                    self.animateView.center.x = self.scrollBarView.center.x
                }
            }
        }
    }
}

// MARK: - Touch

extension PlaylistListViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            
            return
        }
        
        if musicManager.playlists.count == 0 || !isActive {
            
            return
        }
        
        if let count = items?.count {
            
            length = (kItemSize / 2 * 3 + 20.0) * CGFloat(count > 0 ? count - 1 : 0)
            length = length == 0 ? 1 : length
        }
        
        if isInside(inView: thumbView, point: touch.location(in: view)) {
            
            isTouching = true
            
            helperConstraint.constant = 75
            UIView.animate(withDuration: 0.5, animations: {
                
                self.scrollBarView.alpha = 1.0
                self.view.layoutIfNeeded()
                
            })
            delegate.hideMasterView()
            helperTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(helperTimerExec), userInfo: false, repeats: true)
            helperTimer.fire()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            
            return
        }
        
        if isTouching && isActive {
            
            playConstraint.constant += touch.location(in: view).x - touch.previousLocation(in: view).x
            (parent as! MasterViewController).playerViewController.view.center.x += touch.location(in: view).x - touch.previousLocation(in: view).x
            if playConstraint.constant > 0 {
                
                updateSliderConstraint(touch)
                playConstraint.constant = 0
                selectFlag = false
            } else if playConstraint.constant > -20.0 {
                
                updateSliderConstraint(touch)
                selectFlag = false
            } else if playConstraint.constant < -80.0 {
                
                isTouching = false
                selectFlag = false
                isActive = false
                delegate.switchPlayerViewController(self, sender: selectorPosition)
                timerCount += 1
            } else {
                
                let rate = playConstraint.constant / -150.0
                if rate > 0.5 {
                    
                    selectFlag = true
                } else {
                    
                    selectFlag = false
                }
            }
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isActive {
            
            UIView.animate(withDuration: 0.5, animations: {
                
                (self.parent as! MasterViewController).playerViewController.view.center.x = UIScreen.main.bounds.width / 2 * 3
            })
            
            delegate.showMasterView()
        }
        playConstraint.constant = 0.0
        selectFlag = false
        isTouching = false
        helperConstraint.constant = -18
        UIView.animate(withDuration: 0.5, animations: {
            
            self.scrollBarView.alpha = 0.0
            self.view.layoutIfNeeded()
        })
        if helperTimer != nil && helperTimer.isValid {
            
            animateView.center.x = scrollBarView.center.x
            helperTimer.invalidate()
        }
    }
    
    func updateSliderConstraint(_ touch: UITouch) {
        
        sliderConstraint.constant += touch.location(in: view).y - touch.previousLocation(in: view).y
        if sliderConstraint.constant < 0 {
            
            sliderConstraint.constant = 0
        } else if sliderConstraint.constant > scrollBarView.frame.height - thumbView.frame.height {
            
            sliderConstraint.constant = scrollBarView.frame.height - thumbView.frame.height
        }
        animateView.center.y = thumbView.center.y
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

// MARK: - CollectionView

extension PlaylistListViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return musicManager.playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistCollectionViewCell.defaultReuseIdentifier, for: indexPath) as! PlaylistCollectionViewCell
        cell.currentAlbum = indexPath.row
        cell.miniTitleLabel.isHidden = true
        
        let centerX = cell.center.x - collectionView.contentOffset.x
        let ratio = 1.0 - fabs(view.bounds.width / 2 - centerX) / centerThreshold
        if ratio > 0.0 {
            
            cell.transform = CGAffineTransform(scaleX: 1.0 + 0.5 * ratio, y: 1.0 + 0.5 * ratio)
        } else {
            
            cell.transform = .identity
        }
        
        if indexPath.row == selectorPosition {
            
            cell.selectionView.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                
                collectionView.bringSubview(toFront: cell)
            })
        } else {
            
            cell.selectionView.isHidden = false
        }
        
        if indexPath.row == musicManager.currentAlbum {
            
            cell.animationView.isHidden = false
            cell.animationView.play()
        } else {
            
            cell.animationView.isHidden = true
            cell.animationView.pause()
        }
        
        cell.miniTitleLabel.pauseLabel()
        
        return cell
    }
}

extension PlaylistListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        let centerX = cell!.center.x - collectionView.contentOffset.x
        let ratio = 1.0 - fabs(view.bounds.width / 2 - centerX) / centerThreshold
        
        if ratio > 0.0 {
            
            delegate.switchPlayerViewController(self, sender: indexPath.row)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        animateCell(scrollView)
        UIView.animate(withDuration: 0.5, animations: {
            
            self.scrollBarView.alpha = 1.0
        })
        delegate.hideMasterView()
        if let count = items?.count {
            
            length = (kItemSize / 2 * 3 + 20.0) * CGFloat(count > 0 ? count - 1 : 0)
            length = length == 0 ? 1 : length
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        sliderConstraint.constant = (scrollBarView.frame.height - thumbView.frame.height) * scrollView.contentOffset.x / length
        animateView.center.y = thumbView.center.y
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
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if !isTouching && !decelerate {
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.scrollBarView.alpha = 0.0
            })
            delegate.showMasterView()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if !isTouching {
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.scrollBarView.alpha = 0.0
            })
            delegate.showMasterView()
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

extension PlaylistListViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        let text = "プレイリストがありません"
        let font = UIFont.systemFont(ofSize: 25)
        return NSAttributedString(string: text, attributes: [NSFontAttributeName: font])
    }
    
    func buttonImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> UIImage! {
        
        return #imageLiteral(resourceName: "Group")
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        
        collectionView.reloadData()
    }
}

// MARK: - Music

extension PlaylistListViewController {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "currentAlbum" {
            
            collectionView.reloadData()
        }
    }
}

// MARK: - StoryboardInstantiable

extension PlaylistListViewController: StoryboardInstantiable {
    
    static var storyboardName: String {
        
        return String(describing: self)
    }
}
