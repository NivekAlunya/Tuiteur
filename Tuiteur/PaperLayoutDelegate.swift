//
//  PaperLayoutDelegate.swift
//  pocApp
//
//  Created by Kevin Launay on 5/9/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import UIKit

protocol PaperLayoutDelegate: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, itemInsetsForSectionAtIndex: Int) -> UIEdgeInsets
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
//    @available(iOS 6.0, *)
//    optional public func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool
//    
//    @available(iOS 6.0, *)
//    optional public func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath)
//    
//    @available(iOS 6.0, *)
//    optional public func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath)
//    
//    @available(iOS 6.0, *)
//    optional public func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool
//    
//    @available(iOS 6.0, *)
//    optional public func collectionView(collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: NSIndexPath) -> Bool // called when the user taps on an already-selected item in multi-select mode
//    
//    @available(iOS 6.0, *)
//    optional public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
//    
//    @available(iOS 6.0, *)
//    optional public func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath)
//    
//    @available(iOS 8.0, *)
//    optional public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath)
//    
//    @available(iOS 8.0, *)
//    optional public func collectionView(collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, atIndexPath indexPath: NSIndexPath)
//    
//    @available(iOS 6.0, *)
//    optional public func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath)
//    
//    @available(iOS 6.0, *)
//    optional public func collectionView(collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, atIndexPath indexPath: NSIndexPath)
//    
//    // These methods provide support for copy/paste actions on cells.
//    // All three should be implemented if any are.
//    @available(iOS 6.0, *)
//    optional public func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool
//    
//    @available(iOS 6.0, *)
//    optional public func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool
//    
//    @available(iOS 6.0, *)
//    optional public func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?)
//    
//    // support for custom transition layout
//    @available(iOS 7.0, *)
//    optional public func collectionView(collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout
//    
//    // Focus
//    @available(iOS 9.0, *)
//    optional public func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool
//    
//    @available(iOS 9.0, *)
//    optional public func collectionView(collectionView: UICollectionView, shouldUpdateFocusInContext context: UICollectionViewFocusUpdateContext) -> Bool
//    
//    @available(iOS 9.0, *)
//    optional public func collectionView(collectionView: UICollectionView, didUpdateFocusInContext context: UICollectionViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator)
//    
//    @available(iOS 9.0, *)
//    optional public func indexPathForPreferredFocusedViewInCollectionView(collectionView: UICollectionView) -> NSIndexPath?
//    
//    @available(iOS 9.0, *)
//    optional public func collectionView(collectionView: UICollectionView, targetIndexPathForMoveFromItemAtIndexPath originalIndexPath: NSIndexPath, toProposedIndexPath proposedIndexPath: NSIndexPath) -> NSIndexPath
//    
//    @available(iOS 9.0, *)
//    optional public func collectionView(collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint // customize the content offset to be applied during transition or update animations

}
