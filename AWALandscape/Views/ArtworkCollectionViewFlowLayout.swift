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
    
    //
    //    var position: Int = 0 {
    //
    //        didSet {
    //
    //            if oldValue != position {
    //
    //                cellSize = []
    //                for i in 0 ..< collectionView!.numberOfItems(inSection: 0) {
    //
    //                    cellSize.append(calcurateCellSize(at: i))
    //                }
    //            }
    //        }
    //    }
    //
    //    var cellSize: [CGRect]!
    //
    //    private func calcurateCellSize(at index: Int) -> CGRect {
    //
    //        let itemLength = ArtworkCollectionViewFlowLayout.kItemLength
    //
    //        if index == position {
    //
    //            let x = sectionInset.left + (minimumInteritemSpacing + itemLength) * CGFloat(index - 1)
    //            let y = sectionInset.top
    //            let width = itemLength * 1.2
    //            let height = itemLength * 1.2 + 50
    //            return CGRect(x: x, y: y, width: width, height: height)
    //        } else if index < position {
    //
    //            let x = sectionInset.left + (minimumInteritemSpacing + itemLength) * CGFloat(index - 1)
    //            let y = sectionInset.top + itemLength * 0.2
    //            return CGRect(x: x, y: y, width: itemLength, height: itemLength)
    //        } else {
    //
    //            let x = sectionInset.left + (minimumInteritemSpacing + itemLength) * CGFloat(index - 1) + itemLength * 0.2
    //            let y = sectionInset.top + itemLength * 0.2
    //            return CGRect(x: x, y: y, width: itemLength, height: itemLength)
    //        }
    //    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        //        let itemLength = ArtworkCollectionViewFlowLayout.kItemLength
        //        let verticalInset = ArtworkCollectionViewFlowLayout.verticalInset
        //        let horizontalInset = ArtworkCollectionViewFlowLayout.horizontalInset
        //
        //        itemSize = CGSize(width: 0, height: 0)
        //        estimatedItemSize = CGSize(width: itemLength, height: itemLength + 50)
        //        minimumLineSpacing = 20.0
        //        minimumInteritemSpacing = 20.0
        //        scrollDirection = .horizontal
        //
        //        sectionInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset)
        //
        //        if let collectionView = collectionView {
        //
        //            cellSize = []
        //            for i in 0 ..< collectionView.numberOfItems(inSection: 0) {
        //
        //                cellSize.append(calcurateCellSize(at: i))
        //            }
        //        }
    }
    
    //    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    //
    //        var attributes = [UICollectionViewLayoutAttributes]()
    //
    //        if let collectionView = collectionView {
    //
    //            for i in 0 ..< collectionView.numberOfItems(inSection: 0) {
    //
    //                if let attribute = layoutAttributesForItem(at: IndexPath(row: i, section: 0)) {
    //
    //                    if rect.intersects(attribute.frame)  {
    //
    //                        attributes.append(attribute)
    //                    }
    //                }
    //            }
    //        }
    //        return attributes
    //    }
    //
    //    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    //
    //        let attr = super.layoutAttributesForItem(at: indexPath)
    //        attr?.frame = calcurateCellSize(at: indexPath.row)
    //        return attr
    //    }
    //
    //    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    //
    //        return true
    //    }
    
    // MARK: - CoverFlow Layout
    // https://www.slideshare.net/sawat1203/uicollectionviewlayout-15447285
    
    //    private var count: Int {
    //
    //        get {
    //
    //            return collectionView?.numberOfItems(inSection: 0) ?? 0
    //        }
    //    }
    //    private var cellInterval: CGFloat = ArtworkCollectionViewFlowLayout.kItemLength / 3.0
    //    private var cellSize: CGSize!
    //    private var centerRateThreshold: CGFloat!
    //
    //    override var collectionViewContentSize: CGSize {
    //
    //        get {
    //
    //            var size = collectionView!.bounds.size
    //            size.width = CGFloat(count) * cellInterval
    //            return size
    //        }
    //    }
    //
    //    func indexPathsForItem(in rect: CGRect) -> [IndexPath] {
    //
    //        let cw = cellInterval
    //        let minRow = Int(max(0, floor(rect.origin.x / cw)))
    //
    //        var indexPaths = [IndexPath]()
    //        var index = minRow
    //        while index < count && CGFloat(index-1) * cw < rect.origin.x + rect.size.width {
    //
    //            indexPaths.append(IndexPath(row: index, section: 0))
    //            index += 1
    //        }
    //        return indexPaths
    //    }
    //
    //    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    //
    //        let indices = indexPathsForItem(in: rect)
    //        var attributes = [UICollectionViewLayoutAttributes]()
    //        for indexPath in indices {
    //
    //            attributes.append(layoutAttributesForItem(at: indexPath)!)
    //        }
    //        return attributes
    //    }
    //
    //    func rate(for cellOffsetX: CGFloat) -> CGFloat {
    //
    //        let boundsWidth = collectionView!.bounds.size.width
    //        let offsetFromCenter = cellOffsetX + cellSize.width / 2 - (collectionView!.contentOffset.x + boundsWidth / 2)
    //        let rate = offsetFromCenter / boundsWidth
    //        return min(max(-1.0, rate), 1.0)
    //    }
    //
    //    func translateX(forDistanceRate rate: CGFloat) -> CGFloat {
    //
    //        if CGFloat(fabsf(Float(rate))) < centerRateThreshold {
    //
    //            return (rate / centerRateThreshold) * cellSize.width / 2
    //        }
    //        return CGFloat(copysignf(1.0, Float(rate))) * cellSize.width / 2
    //    }
    //
    //    func translateZ(forDistanceRate rate: CGFloat) -> CGFloat {
    //
    //        if CGFloat(fabsf(Float(rate))) < centerRateThreshold {
    //
    //            return -1.0 - 2.0 * cellSize.width * (1.0 - cos((rate / centerRateThreshold) * .pi / 2))
    //        }
    //        return -1.0 - 2.0 * cellSize.width
    //    }
    //
    //    func transform(with cellOffsetX: CGFloat) -> CATransform3D {
    //
    //        let zDist: CGFloat = 800.0
    //        let r = rate(for: cellOffsetX)
    //        var t = CATransform3DIdentity
    //        t.m34 = 1.0 / -zDist
    //        t = CATransform3DTranslate(t, translateX(forDistanceRate: r), 0.0, translateZ(forDistanceRate: r))
    //
    ////        let a = angle(forDistanceRate: r)
    ////        t = CATransform3DRotate(t, a, 0.0, 1.0, 0.0)
    //        return t
    //    }
    //
    //    func angle(forDistanceRate rate: CGFloat) -> CGFloat {
    //
    //        let baseAngle: CGFloat = -1.0 * .pi * 80 / 180
    //        if CGFloat(fabsf(Float(rate))) < centerRateThreshold {
    //
    //            return CGFloat(copysignf(1.0, Float(rate))) * baseAngle
    //        }
    //        return (rate / centerRateThreshold) * baseAngle
    //    }
    //
    //    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    //
    //        let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
    //
    //        let offsetX = CGFloat(indexPath.item) * cellInterval
    //        var frame = CGRect()
    //        frame.origin.x = offsetX
    //        frame.origin.y = (collectionView!.bounds.size.height - cellSize.height) / 2.0
    //        frame.size = cellSize
    //        
    //        attr.frame = frame
    //        
    //        attr.transform3D = transform(with: offsetX)
    //        
    //        return attr
    //    }
    //
    //    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    //        
    //        return true
    //    }
}
