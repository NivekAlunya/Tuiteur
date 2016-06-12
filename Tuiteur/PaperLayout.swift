//
//  PaperLayout.swift
//  pocApp
//
//  Created by Kevin Launay on 5/9/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import UIKit

class PaperLayout: UICollectionViewLayout {
    
    private var delegate: PaperLayoutDelegate?
    private var sections: [PaperLayoutSection]!
    private var height =  CGFloat(0)
    var headerHeight = CGFloat(0)
    
    func getItemSizeAtIndex(indexPath: NSIndexPath) -> CGRect {
        return sections[indexPath.section].items[indexPath.row]!
    }

    func setItemSizeAtIndex(indexPath: NSIndexPath, rect: CGRect) -> CGRect {
        return sections[indexPath.section].items[indexPath.row]!
    }

    override func prepareLayout() {
        print("preparelayout")
        super.prepareLayout()
        
        guard let collectionView = self.collectionView
            , delegate = collectionView.delegate as? PaperLayoutDelegate else {
            return
        }

        sections = [PaperLayoutSection]()
        height = CGFloat(0)
        
        var currentOrigin = CGPointZero
        
        let numberOfSections = collectionView.numberOfSections()
        
        for i in 0 ..< numberOfSections {
            height += self.headerHeight
            currentOrigin.y = height
            print("From section \(i)) position is \(currentOrigin)")
            
            let numberOfItems = collectionView.numberOfItemsInSection(i)
            
            let itemInsets = delegate.collectionView(collectionView, layout: self, itemInsetsForSectionAtIndex: i) ?? UIEdgeInsetsZero
            
            let section = PaperLayoutSection(origin: currentOrigin, width: collectionView.bounds.size.width ?? 0.0, itemInsets: itemInsets)
            
            for j in 0 ..< numberOfItems {
                let index = NSIndexPath(forItem: j, inSection: i)
                let itemSize = delegate.collectionView(collectionView, layout: self, sizeForItemAtIndexPath: index)
                section.addItemOfSize(itemSize, forIndex: j)
            }
            
            sections.append(section)
            
            height += section.frame.height
            
        }
    }
    
    override func collectionViewContentSize() -> CGSize {
        guard let collectionView = self.collectionView else {
            return CGSizeZero
        }
        return CGSize(width: collectionView.bounds.size.width, height: height)
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let section = sections[indexPath.section]
        let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        attributes.frame = section.frameForItemAtIndex(indexPath.item)
        return attributes
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let section = sections[indexPath.section]
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)
        
        let headerFrame = getHeaderFrameForSection(section)

        attributes.frame = headerFrame

        return attributes
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = [UICollectionViewLayoutAttributes]()
        for (sectionIndex, section) in sections.enumerate() {
            let headerFrame = getHeaderFrameForSection(section)
            if CGRectIntersectsRect(headerFrame, rect) {
                let indexPath = NSIndexPath(forItem: 0, inSection: sectionIndex)
                let attribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withIndexPath: indexPath)
                attributes.append(attribute)
            }
            if CGRectIntersectsRect(section.frame, rect) {
                for i in 0 ..< section.numberOfItems {
                    let frame = section.frameForItemAtIndex(i)
                    if CGRectIntersectsRect(frame, rect) {
                        let indexPath = NSIndexPath(forItem: i, inSection: sectionIndex)
                        if let attribute = layoutAttributesForItemAtIndexPath(indexPath) {
                            attributes.append(attribute)
                        }
                    }
                }
            }
        }
        
        return attributes
    }
    
    private func getHeaderFrameForSection(section: PaperLayoutSection) -> CGRect {
        return CGRectMake(0.0, section.frame.origin.y - headerHeight, section.frame.size.width, headerHeight)
    }
}
