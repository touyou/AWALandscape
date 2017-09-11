//
//  ArtworkCollectionViewFlowLayout.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/06.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit

class ArtworkCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    static let kItemLength: CGFloat = UIScreen.main.bounds.size.height / 2
    static let horizontalInset = (UIScreen.main.bounds.size.width - kItemLength) / 2
    static let verticalInset = (UIScreen.main.bounds.size.height - kItemLength) / 2
    
    var dynamicAnimator: UIDynamicAnimator!
    private var visibleIndexPaths = Set<IndexPath>()
    private var addedBehaviors = [IndexPath: UIAttachmentBehavior]()
    
    override init() {
        
        super.init()
        dynamicAnimator = UIDynamicAnimator(collectionViewLayout: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        dynamicAnimator = UIDynamicAnimator(collectionViewLayout: self)
    }
    
    override func prepare() {
        
        super.prepare()
        
        guard let collectionView = self.collectionView else {
            
            return
        }
        
        collectionView.layoutIfNeeded()
        
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size).insetBy(dx: -100, dy: 0)
        guard let visibleItems = super.layoutAttributesForElements(in: visibleRect) else {
            
            return
        }
        let visibleIndexPaths = visibleItems.map { $0.indexPath }
        let noLongerVisibleIndexPaths = self.visibleIndexPaths.subtracting(visibleIndexPaths)
        for indexPath in noLongerVisibleIndexPaths {
            
            if let behavior = addedBehaviors[indexPath] {
                
                dynamicAnimator.removeBehavior(behavior)
                addedBehaviors.removeValue(forKey: indexPath)
            }
        }
        
        self.visibleIndexPaths = Set(visibleIndexPaths)
        for item in visibleItems {
            
            if let _ = addedBehaviors[item.indexPath] {
                
                continue
            }
            
            let behavior = UIAttachmentBehavior(item: item, attachedToAnchor: item.center)
            behavior.length = 0
            behavior.damping = 0.9
            behavior.frequency = 1.0
            
            dynamicAnimator.addBehavior(behavior)
            addedBehaviors[item.indexPath] = behavior
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        return dynamicAnimator.items(in: rect) as? [UICollectionViewLayoutAttributes]
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        return dynamicAnimator.layoutAttributesForCell(at: indexPath)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        
        guard let collectionView = collectionView else {
            
            return false
        }
        let contentOffset = collectionView.contentOffset.x
        let contentSize = collectionView.contentSize.width
        let collectionViewSize = collectionView.bounds.size.width
        if contentOffset < 0 || contentOffset + collectionViewSize > contentSize {
            
            return false
        }
        
        let scrollDistance = newBounds.origin.x - collectionView.bounds.origin.x
        let touchLocation = collectionView.panGestureRecognizer.location(in: collectionView)
        
        for behavior in dynamicAnimator.behaviors {
            
            if let behavior = behavior as? UIAttachmentBehavior {
                
                if let item = behavior.items.first {
                    
                    let distanceFromTouch = fabs(touchLocation.x - item.center.x)
                    let scrollResistance = distanceFromTouch / 1500
                    let offset = scrollDistance * scrollResistance
                    
                    item.center.x += offset
                    dynamicAnimator.updateItem(usingCurrentState: item)
                }
            }
        }
        return false
    }
}
